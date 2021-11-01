local State = {}

function State:new(name, ...)
	local object = setmetatable({
		super = self;
		Name = name;
	}, {
		__index = self
	})
	object:init(...)
	return object
end
local nilUpdate = function() --[[print("NIL UPDATE")]] end
local nilEnter = function() --[[print("NIL ENTER")]] end
local nilExit = function() --[[print("NIL EXIT")]] end
function State:init(update, enter, exit)
	self.transitions = {}
	self.transitions[self.Name] = true
	self.update = update or nilUpdate
	self.enter = enter or nilEnter
	self.exit = exit or nilExit
end
function State:isTransitionValid(stateName)
	return self.transitions[stateName] or false
end
function State:addTransition(stateName)
	self.transitions[stateName] = true
	return self
end


local FSM = {}
function FSM:new(name, ...)
	local object = setmetatable({
		Name = name;
	}, {
		__index = self
	})
	object:init(...)
	return object
end

function FSM:init()
	self.states = {}
	self.statesCount = 0
	self.current = false
end
function FSM:addState(--[[state]] stateName, update, enter, exit)
	-- assert(type(state) == "table", "state must be a table, got " .. type(state))
	-- assert(state.super and state.super == State, string.format("object %q is not a state", tostring(state)))
	-- self:getState(state)Name] = state
	local state = State:new(stateName, update, enter, exit)
	self.states[stateName] = state
	return state
end
function FSM:setState(stateName, enter)
	assert(self:getState(stateName), string.format("State %q does not exist", stateName), 2)
	self.current = self:getState(stateName)
	if enter then
		self.current.enter()
	end
end
function FSM:getState(stateName)
	return self.states[stateName]
end
function FSM:transition(stateName, ...)
	assert(self.current:isTransitionValid(stateName), string.format("State %q does not transition to state %q", self.current.Name, stateName), 2)
	self.current.exit(...)
	self.current = self:getState(stateName)
	self.current.enter(...)
end
function FSM:isState(stateName)
	return self.current.Name == stateName
end
function FSM:update(...)
	self.current.update(...)
end
function FSM:validate(verbose)
	local printf = verbose and printf or function() end
	assert(self.current, "FSM needs a starting state, no states given", 2)
	local startState = self.current
	local reached = {}
	local stack = Feint.Core.DataStructures.Stack:new()

	stack:push(self.current)
	while stack.size > 0 do
		local state = stack:pop()
		reached[state.Name] = true
		printf("Validating state %q\n", state.Name)
		for transition in pairs(state.transitions) do
			printf("   Validating transition %q\n", transition)
			if self:getState(transition) then
				if transition ~= startState.Name and transition ~= state.Name then
					stack:push(self:getState(transition))
				end
			else
				printf("   FSM Warning: state %q cannot transition to state %q: does not exist\n", state.Name, transition)
			end
		end
	end
	for stateName, state in pairs(self.states) do
		if not reached[stateName] then
			printf("FSM Warning: state %q is unreachable through transitions\n", stateName)
		end
	end
end

return FSM
