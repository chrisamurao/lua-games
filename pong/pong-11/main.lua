--[[
  Pong
  "Pong 1.1 - Sound"

  -- Main Program --

]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
--  https://github.com/Ulydev/push

push = require 'push'


-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

IS_LOVE11 = love.getVersion() == 11

-- speed at whcih we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- init sound effects, later, we can just index this table and call each entry's play method
    sounds = {
      ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
      ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
      ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    --game state variable used to transition between different pars of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

function love.update(dt)

  if gameState == 'serve' then
    --before switching to play, initialize the ball's velocity based
    --on player who last scored
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  elseif gameState == 'play' then
    -- detect ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position of collision
    
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      -- keey velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      --leey velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end

    --detect upper and lower screen boundary collision and reverse if collided
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end

    -- -4 to account for the size of the ball
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT -4
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end
    
    -- if we reach the left or right edge of the screen, 
    -- go back to start and update the score
    if ball.x < 0 then
      servingPlayer = 1
      player2Score = player2Score + 1
      sounds['score']:play()
      
      --if we've reached a score of 10, the game is over; set the
      --state to done so we can show the victory message
      
      if player2Score == 3 then
        winningPlayer = 2
        gameState = 'done'
      else
        ball:reset()
        gameState = 'serve'
      end
    end
    
    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      sounds['score']:play()
      
      if player1Score == 3 then
        winningPlayer = 1
        gameState = 'done'
      else 
        ball:reset()
        gameState = 'serve'
      end
    end
  end
    
    --player 1 movement
  if love.keyboard.isDown('w') then
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else 
    player1.dy = 0
  end 

  --player 2 movement

  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else 
    player2.dy = 0
  end 


  -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent

  player1:update(dt)
  player2:update(dt)

  if gameState == 'play' then
    ball:update(dt)
  end

end
  

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
    elseif gameState == 'done' then
      --game is simply in a restart phase here, but will set the serving
      --player to the opponent of whomenver won for fairness
      gameState = 'serve'
      ball:reset()

      --reset scores to 0
      player1Score = 0
      player2Score = 0
      
      --decide serving player as the opposite of who won
      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end

    end
  end
end


function love.draw()
    push:apply('start')

    local r, g, b, a = 
      (IS_LOVE11 and 40 / 255) or 40,
      (IS_LOVE11 and 45 / 255) or 45,
      (IS_LOVE11 and 52 / 255) or 52,
      (IS_LOVE11 and 255 / 255) or 255
    
    love.graphics.clear(r, g, b, a)

    -- draw welcome text toward the top of the screen
    love.graphics.setFont(smallFont)
    displayScore()

    if gameState == 'start' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.printf('Press Enter to Begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
      --no UI messages to display in play

    elseif gameState == 'done' then
      --UI messages
      love.graphics.setFont(largeFont)
      love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins', 0, 10, VIRTUAL_WIDTH, 'center')
      love.graphics.setFont(smallFont)
      love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing

    player1:render()
    player2:render()

    --render ball using it's class' render method
    ball:render()

    displayFPS()

    push:apply('end')
end

--[[
  Renders the games frames per second
]]

function displayFPS()
  --displays across all states

  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
  --draw score on the left and right center of the screen
  --need to switch font to draw before actually printing
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
    VIRTUAL_WIDTH / 3 - 40)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
    VIRTUAL_WIDTH / 3 - 40)
end
  