--[[
  Flappy Bird

  v0.4 - Anti-Gravity update

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
require 'bird'

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

-- bird sprite
local bird = Bird()


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
  -- scroll background by preset speed * dt, looping back to 0 after the looping point
  backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
    % BACKGROUND_LOOPING_POINT

  -- scroll ground by preset speed * dt, looping back to 0 after the screen width passes
  groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
    % VIRTUAL_WIDTH

    bird:update(dt)

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

  --draw the ground on top of the background, toward the bottom of the screen
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16) 
  
  bird:render()

  push:finish()
end 