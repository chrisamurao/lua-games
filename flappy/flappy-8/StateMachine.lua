--[[
  StateMachine - a state machine

  Usage:

  States are only created as needed, to save memory, reduce cleanup bugs and increase speed
  due to garbage collection taking longer with more data in memory.

  States are added witha s tring identifier and an initialization function
  It is expecting the init function, which when called, will return a table
  with Render, Update and Enter and Exit methods.

  gStateMachine = StateMachine {
    ['MainMenu'] = function()
      return MainMenu()
    end,
    ['InnerGame'] = function()
      return InnerGame()
    end,
    ['GameOver'] = function()
      return GameOver()
    end,
  }
  gStateMachine:change("MainGame")

  Arguments passed into the Change function after the state name will be forwarded to 
    the Enter function of the state being changed to

  State identifiers should have the same name as the state table, unless there's a good
  reason not to. i.e. MainMenu creates a state using the MainMenu table. This keeps
  things straightforward.


  ]]

StateMachine = Class{}

function StateMachine:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
end

function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:render()
	self.current:render()
end