--[[
  Flappy Bird

  * Procedural generation
  * Animated characters (sprites)
  * State Machines
  * Mouse input
  * Infinite Scrolling

]]

--push to handle resolution
push = require 'push'

--physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load background images into memory to be drawn later
local background = love.graphics.newImage('background.png')
local ground = love.graphics.newImage('ground.png')

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
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.draw()
  push:start()

  --draw the background starting at top left (0, 0)
  love.graphics.draw(background, 0, 0)
  --draw the ground on top of the background, toward the bottom of the screen

  push:finish()
end 