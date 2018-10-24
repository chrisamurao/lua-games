--[[
  Flappy Bird

  v0.8 - State Machine update

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

-- import pipe class
require 'Pipe'

-- import pipe pair
require 'PipePair'

-- import state machine code
require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreenState'

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

-- scrolling flag used to pause the game when we collide with a pipe
local scrolling = true

function love.load()
  --initialize nearest-neighbor filter
  love.graphics.setDefaultFilter('nearest', 'nearest')

  --app window title
  love.window.setTitle('Flappy Bird')

  -- initialize fonts
  smallFont = love.graphics.newFont('font.ttf', 8)
  mediumFont = love.graphics.newFont('flappy.ttf', 14)
  flappyFont = love.graphics.newFont('flappy.ttf', 28)
  hugeFont = love.graphics.newFont('font.ttf', 56)
  love.graphics.setFont(flappyFont)

  -- initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false, 
    resizable = true
  })

  -- initialize state machine will all state-returning functions
  gStateMachine = StateMachine {
    ['title'] = function() return TitleScreenState() end,
    ['play'] = function() return PlayState() end,
  }
  gStateMachine:change('title')

  --initialize input table
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
    % GROUND_LOOPING_POINT

  -- we just update the state machine, which defers to the right state
  gStateMachine:update(dt)

  --reset input table
  love.keyboard.keysPressed = {}
end


function love.draw()
  push:start()

  --draw the background starting at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)
  --draw the ground on top of the background, toward the bottom of the screen
  gStateMachine:render()
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16) 
  
  push:finish()
end 