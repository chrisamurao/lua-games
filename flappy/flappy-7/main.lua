--[[
  Flappy Bird

  v0.7 - Collision update

  * Procedural generation
  * Animated characters (sprites)
  * State Machines
  * Mouse input
  * Infinite Scrolling

]]

--push to handle resolution
push = require 'push'

-- classes library 
Class = require 'class'

-- add bird class
require 'Bird'

--import pipe class
require 'Pipe'

--import pipe pair
require 'PipePair'

--physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load background images into memory to be drawn later
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

-- speed at which we should scroll our images, scaled by dt
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X.0
local BACKGROUND_LOOPING_POINT = 413

-- point at which we should loop our ground back to X 0
local GROUND_LOOPING_POINT = 514

-- bird sprite
local bird = Bird()

-- our table of spawning Pipes
local pipePairs = {}

-- our timer for spawning pipes
local spawnTimer = 0

-- init our last recorded Y value for a gap placement to base other gaps off of
local lastY = -PIPE_HEIGHT + math.random(80) + 20

-- scrolling flag used to pause the game when we collide with a pipe
local scrolling = true

function love.load()
  --initialize nearest-neighbor filter
  love.graphics.setDefaultFilter('nearest', 'nearest')

  --app window title
  love.window.setTitle('Flappy Bird')

  -- initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false, 
    resizable = true
  })

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)

  love.keyboard.keysPressed[key] = true

  if key == 'escape' then
    love.event.quit()
  end
end

--[[ 
  New function used to check our global input table for keys we activated during this frame, looked up by their string value
]]

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then 
    return true
  else
    return false
  end
end

function love.update(dt)

  if scrolling then
    -- scroll background by preset speed * dt, looping back to 0 after the looping point
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
      % BACKGROUND_LOOPING_POINT

    -- scroll ground by preset speed * dt, looping back to 0 after the screen width passes
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
      % GROUND_LOOPING_POINT

    spawnTimer = spawnTimer + dt

    --spawn a new Pipe if the timer is past 2 seconds
    if spawnTimer > 2 then
      -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
      -- no higher than 10 pixels below the top edge of the screen,
      -- and no lower than a gap length (90 pixels) from the bottom

      local y = math.max(-PIPE_HEIGHT + 10, 
        math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
      lastY = y

      table.insert(pipePairs, PipePair(y))
      spawnTimer = 0
    end

    -- update the bird for input and gravity
    bird:update(dt)

    -- for every pipe in the scene...
    for k, pair in pairs(pipePairs) do
        pair:update(dt)

        -- check to see if bird collided with pipe
        for l, pipe in pairs(pair.pipes) do
          if bird:collides(pipe) then
            --pause the game to show collision
            scrolling = false
          end
        end
        
    end

    --remove any flagged pipes
    --we need this second loop, rather than deleting in the previous loop, becuase
    -- modifying the table in-place without explicity keys will result in skipping the
    --next pipe, since all implicity keys (numerical indices) are automatically shifted
    --down after a table removal 
    for k, pair in pairs(pipePairs) do
          -- if pipe is no longer visible past left edge, remove it from scene
      if pair.remove then
        table.remove(pipePairs, k)
      end
    end
  end
  --reset input table
  love.keyboard.keysPressed = {}
end


function love.draw()
  push:start()

  --[[
    here, we draw our images shifted to the left by their looping point; eventually,
    they will revert back to 0 once a certain distance has elapsed, which will make it
    seem as if they are infinitely scrolling. Choosing a looping point that is seamless
    is key, as to provide the illusion of looping
  ]]

  --draw the background starting at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)

  -- render all the pipes in our scene
  for k, pair in pairs(pipePairs) do
    pair:render()
  end

  --draw the ground on top of the background, toward the bottom of the screen
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16) 
  
  bird:render()

  push:finish()
end 