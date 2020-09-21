local inputContext = {}
function inputContext:new(name, ...)
	local newInputContext = {}
	newInputContext.name = name

	local mt = {}
	mt.__index = self
	setmetatable(newInputContext, mt)

	if newInputContext.init then
		-- print(...)
		newInputContext:init(...)
	end

	return newInputContext
end
local Feint_InputCommand = require(Feint_INPUT_PATH.."/InputCommand", true)
function inputContext:init()
	self.inputs = MappedArray("k")
end
function inputContext:addInput(name, ...)
	local input = Feint_InputCommand:new(name, ...)
	-- self.inputs[#self.inputs+1] = input
	self.inputs:add(input, name)
	return input
end
function inputContext:getInput(name)
	return self.inputs:getLUT(name)
end
function inputContext:handleInput(mouse)
	for _, command in pairs(self.inputs.values) do
		command:update(mouse)
	end
end

return inputContext
