local inputCommand = {}
function inputCommand:new(name, ...)
	local newInputCommand = {}
	newInputCommand.name = name

	local mt = {}
	mt.__index = self
	setmetatable(newInputCommand, mt)

	if newInputCommand.init then
		newInputCommand:init(...)
	end

	return newInputCommand
end
local function updateMousePosition(self, mouse, x, y)
	mouse.PositionRawOld = mouse.PositionRaw
	mouse.PositionRaw.x, mouse.PositionRaw.y = x, screenSize.y - y
	mouse.PositionUnitRawOld = mouse.PositionUnitRaw
	mouse.PositionUnitRaw = mouse.PositionRaw / screenSize

	mouse.PositionOld = mouse.Position
	mouse.Position = mouse.PositionRaw - screenSize / 2
	mouse.PositionUnitOld = mouse.PositionUnit
	mouse.PositionUnit = mouse.Position / screenSize * 2

	mouse.PositionDeltaRawOld = mouse.PositionDeltaRaw
	mouse.PositionDeltaRaw = mouse.PositionRaw - mouse.PositionRawOld
	mouse.PositionDeltaOld = mouse.PositionDelta
	mouse.PositionDelta = mouse.Position - mouse.PositionOld


	mouse.PositionWorldRawOld = vMath.Vec3.new()
	mouse.PositionWorldRaw = vMath.Vec3.new()

	mouse.PositionWorldOld = vMath.Vec3.new()
	mouse.PositionWorld = vMath.Vec3.new()

	mouse.PositionWorldDeltaOld = vMath.Vec2.new()
	mouse.PositionWorldDelta = vMath.Vec3.new()
end
function inputCommand:update(mouse)
	local inactive = true
	local value = nil
	local vectors = nil
	local name = "nil"
	for _, input in pairs(self.inputs) do
		local source = input[1]
		local button = input[2]
		if source == "key" then
			if love.keyboard.isDown(button) then
				inactive = false
				value = {1}
				break
			else
				active = true
				value = {0}
			end
		elseif source == "mouse" then
			if button == "MOVE" then
				updateMousePosition(self, mouse, love.mouse.getPosition())
				local delta = mouse.PositionDelta
				vectors = vMath.Vec2(love.mouse.getPosition())
				if delta.x ~= 0 or delta.y ~= 0 then
					inactive = false
					value = {1}
					break
				else
					inactive = true
					value = {0}
				end
			else
				if love.mouse.isDown(button) then
					inactive = false
					value = {1}
					break
				else
					inactive = true
					value = {0}
				end
			end
		end
	end

	-- printf("%s %s %s %s\n", name, active, value, vectors)
	if not noInputs then
	end
	self.values = value
	self.vectors = vectors
	self:execute(inactive, value, vectors)
end
local EMPTY = {}
function inputCommand:start(values, vectors)
	-- printf("start %s ", self.name)
	-- printf("%s ", values and values[1] or "nil")
	-- printf("%s\n", vectors and vectors[1] or "nil")
end
function inputCommand:hold(values, vectors)
	-- printf("hold %s ", self.name)
	-- printf("%s ", values and values[1] or "nil")
	-- printf("%s\n", vectors and vectors[1] or "nil")
end
function inputCommand:stop(values, vectors)
	-- printf("stop %s ", self.name)
	-- printf("%s ", values and values[1] or "nil")
	-- printf("%s\n", vectors and vectors[1] or "nil")
end
function inputCommand:init(inputSources, start, hold, stop)
	self.state = "idle"
	self.values = {}
	self.vectors = {}
	self.inputs = {}
	self.inputsLast = {}
	self.mousePosition = vMath.Vec2(0, 0)
	self.lastMousePosition = vMath.Vec2(0, 0)

	for _, inputs in pairs(inputSources) do
		local inputSource = inputs[1]
		for i=2, #inputs do
			self.inputs[#self.inputs+1] = {inputSource, inputs[i]}
			self.inputsLast[#self.inputsLast+1] = {inputSource, inputs[i]}
		end
	end

	-- start
	local function executeStart(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self:start(...)
				self.state = "start"
			end
		elseif state == "start" then
			self.state = "idle"
		end

	end
	-- stop
	local function executeStop(self, release, ...)
		local state = self.state
		if release then
			if state == "idle" then
				self:stop(...)
				self.state = "stop"
			elseif state == "stop" then
				self.state = "idle"
			end
		end

	end
	-- hold
	local function executeHold(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self.state = "hold"
			elseif state == "hold" then
				self:hold(...)
			end
		elseif state == "hold" then
			self.state = "idle"
		end
	end
	-- start and stop
	local function executeStartStop(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self:start(...)
				self.state = "start"
			end
		else
			if state == "start" then
				self:stop(...)
				self.state = "stop"
			elseif state == "stop" then
				self.state = "idle"
			end
		end
	end
	-- start and hold
	local function executeStartHold(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self:start(...)
				self.state = "start"
			elseif state == "start" then
				self:hold(...)
				self.state = "hold"
			elseif state == "hold" then
				self:hold(...)
			end
		else
			if state == "hold" then
				self:stop(...)
				self.state = "idle"
			end
		end

	end
	-- hold and stop
	local function executeHoldStop(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self.state = "hold"
			elseif state == "hold" then
				self:hold(...)
			end
		else
			if state == "hold" then
				self:stop(...)
				self.state = "stop"
			elseif state == "stop" then
				self.state = "idle"
			end
		end
	end
	-- all
	local function executeStartHoldStop(self, release, ...)
		local state = self.state
		if not release then
			if state == "idle" then
				self:start(...)
				self.state = "start"
			elseif state == "start" then
				self:hold(...)
				self.state = "hold"
			elseif state == "hold" then
				self:hold(...)
			end
		else
			if state == "hold" then
				self:stop(...)
				self.state = "stop"
			elseif state == "stop" then
				self.state = "idle"
			end
		end
	end

	if start then
		if hold then
			if stop then -- start hold stop
				self.execute = executeStartHoldStop
			else -- start hold
				self.execute = executeStartHold
			end
		else -- start stop
			if stop then
				self.execute = executeStartStop
			else -- start
				self.execute = executeStart
			end
		end
	else
		if hold then
			if stop then -- hold stop
				self.execute = executeHoldStop
			else -- hold
				self.execute = executeHold
			end
		else -- stop
			if stop then
				self.execute = executeStop
			else
				self.execute = executeStartHoldStop
			end
		end
	end
end

return inputCommand
