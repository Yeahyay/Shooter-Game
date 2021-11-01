local FSM = {}
function FSM:new(param)
	local object = setmetatable({
		Name = param.Name or "none"
	}, {
		__index = self
	})
	object:init(param)
	return object
end

function FSM:init(param)
	self.state = param.initial or "idle"
	self.initial = param.initial or "idle"
	self.states = param.states
	for k, v in pairs(self.states) do
		self.states[v] = v
	end
	self.transitions = param.transitions
	self.callbacks = param.callbacks
	local lastTransition
	local validCallbacks = {
		["enter"] = true, ["exit"] = true, ["update"] = true
	}
	for _, state in pairs(self.callbacks.states) do
		for k, v in pairs(state) do
			assert(validCallbacks[k], string.format("callback %q is not valid\n", k))
		end
	end
	for transitionName, transitionData in pairs(param.transitions) do
		self[transitionName] = function(state)
			local transition = self.callbacks.transitions[transitionName]
			-- REPLACE IF'S WITH EMPTY FUNCTIONS?
			if lastTransition ~= transitionName and transition and transition.before then
				transition.before()
			end
			for i = 1, #transitionData, 2 do
				local fromState = transitionData[i]
				local toState = transitionData[i + 1]

				if self.state == fromState then
					local cf = self.callbacks.states[fromState]
					if cf and cf.exit then
						cf.exit()
					end
					self.state = toState
					local ct = self.callbacks.states[toState]
					if ct and ct.enter then
						ct.enter()
					end
				end
			end
			if lastTransition ~= transitionName and transition and transition.after then
				transition.after()
			end
			lastTransition = transitionName
		end
	end
	self.statesCount = 0
end
function FSM:getStateCallbacks(callback)
	if not self.callbacks.states[callback] then
		self.callbacks.states[callback] = {}
	end
	return self.callbacks.states[callback]
end
function FSM:getActionCallbacks(callback)
	if not self.callbacks.transitions[callback] then
		self.callbacks.transitions[callback] = {}
	end
	return self.callbacks.transitions[callback]
end
function FSM:update(...)
	local state = self.callbacks.states[self.state]
	if state and state.update then
		state.update(...)
	end
end
function FSM:getCurrentState()
	return self.state
end
function FSM:getState(state)
	return self.states[state]
end
function FSM:validate(verbose, errorOnWarning)
	local printf = verbose and printf or function() end
	assert(self.state, "FSM needs a starting state, no states given", 2)
	local reached = {}

	for _, state in pairs(self.states) do
		printf("   FSM Info: Validating state %q\n", state)
		for transitionName, transitionData in pairs(self.transitions) do
			for i = 1, #transitionData, 2 do
				local fromState = transitionData[i]
				local toState = transitionData[i + 1]

				if state == fromState then
					reached[toState] = true
				end
			end
		end
	end

	for transitionName, transitionData in pairs(self.transitions) do
		printf("   FSM Info: Validating transition %q\n", transitionName)
		for i = 1, #transitionData, 2 do
			local fromState = transitionData[i]
			local toState = transitionData[i + 1]

			if not self:getState(toState) then
				local msg = string.format("FSM Warning: state %q cannot transition to state %q: does not exist\n", fromState, toState)
				if not errorOnWarning then
					printf("   " .. msg)
				else
					error(msg)
				end
			end
		end
	end

	for _, stateName in pairs(self.states) do
		if not reached[stateName] then
			local msg = string.format("FSM Warning: state %q is unreachable through transitions\n", stateName)
			if not errorOnWarning then
				printf("   " .. msg)
			else
				error(msg)
			end
		end
	end
end

return FSM
