PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()

-- bird sprite
-- local bird = Bird()
  self.bird = Bird()
-- our table of spawning Pipes
-- local pipePairs = {}
  self.pipePairs = {}
-- our timer for spawning pipes
-- local spawnTimer = 0
  self.timer = 0
-- init our last recorded Y value for a gap placement to base other gaps off of
-- local lastY = -PIPE_HEIGHT + math.random(80) + 20
  self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
  self.timer = self.timer + dt

  --spawn a new Pipe if the timer is past 2 seconds
  if self.timer > 2 then
    -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
    -- no higher than 10 pixels below the top edge of the screen,
    -- and no lower than a gap length (90 pixels) from the bottom
    local y = math.max(-PIPE_HEIGHT + 10, 
      math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
    self.lastY = y

    table.insert(self.pipePairs, PipePair(y))
    self.timer = 0
  end

  -- for every pipe in the scene...
  for k, pair in pairs(self.pipePairs) do
    pair:update(dt)
  end

  --remove any flagged pipes
  --we need this second loop, rather than deleting in the previous loop, becuase
  -- modifying the table in-place without explicity keys will result in skipping the
  --next pipe, since all implicity keys (numerical indices) are automatically shifted
  --down after a table removal 
  for k, pair in pairs(self.pipePairs) do
        -- if pipe is no longer visible past left edge, remove it from scene
    if pair.remove then
      table.remove(self.pipePairs, k)
    end
  end

  -- update the bird for input and gravity
  self.bird:update(dt)

  -- check to see if bird collided with pipe
  for k, pair in pairs(self.pipePairs) do
    for l, pipe in pairs(pair.pipes) do
      if self.bird:collides(pipe) then
        --pause the game to show collision
        gStateMachine:change('title')
      end
    end
  end
      
  -- reset if we hit the ground
  if self.bird.y > VIRTUAL_HEIGHT - 15 then
    gStateMachine:change('title')
  end
end


function PlayState:render()
    -- render all the pipes in our scene
  for k, pair in pairs(self.pipePairs) do
    pair:render()
  end

  self.bird:render()
end