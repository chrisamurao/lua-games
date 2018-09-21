--[[
  Pong
  "Low-Res update"

  -- Main Program --

]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
--  https://github.com/Ulydev/push

push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

IS_LOVE11 = love.getVersion() == 11

-- speed at whcih we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)

    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    -- paddle positions on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
end

--[[
  Runs every frame, with "dt" passed in, our delta in seconds
  since the last frame, which LOVE2D supplies us.
]]

function love.update(dt)
  -- player 1 movement
  if love.keyboard.isDown('w') then
    -- add negative paddle speed to current Y scaled by deltaTime
    player1Y = player1Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown('s') then
    -- add positive paddle speed to current Y scaled by deltaTime
    player1Y = player1Y + PADDLE_SPEED * dt
  end

  -- player 2 movement
  if love.keyboard.isDown('up') then
    -- add negative paddle speed to current Y scaled by deltaTime
    player2Y = player2Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown('down') then
    -- add positive paddle speed to current Y scaled by deltaTime
    player2Y = player2Y + PADDLE_SPEED * dt
  end
end
  

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
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
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

    -- render first paddle (left side), now using the players' Y variable
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    push:apply('end')
end
