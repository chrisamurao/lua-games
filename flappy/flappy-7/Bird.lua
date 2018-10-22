Bird = Class{}

local GRAVITY = 20

function Bird:init()


  --load bird image from disk and assign its width and height
  self.image = love.graphics.newImage('bird.png')
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()

  --position bird in the middle of the screen
  self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
  self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

  -- Y velocity; gravity
  self.dy = 0
end

--[[
    AABB collision that expects a pipe, which will have an X and Y and reference
    global pipe width and height values
]]

function Bird:collides(pipe)
  -- offsets : L/U = 2 pixels
  --           R/D = 4 pixels
  -- shrink hitbox to give the player collision leeway
  
  local LU = 2
  local RD = 4
  if (self.x + LU) + (self.width - 4) >= pipe.x and self.x + LU <= pipe.x + PIPE_WIDTH then
    if (self.y + LU) + (self.height - RD) >= pipe.y and self.y + LU <= pipe.y + PIPE_HEIGHT then
      return true
    end
  end

  return false
end

function Bird:update(dt)
  --apply gravity to velocity
  self.dy = self.dy + GRAVITY * dt

  -- add anti-gravity jump
  if love.keyboard.wasPressed('space') then
    self.dy = -5
  end
  
  -- apply current velocity to Y position
  self.y = self.y + self.dy
end

function Bird:render()
  love.graphics.draw(self.image, self.x, self.y)
end