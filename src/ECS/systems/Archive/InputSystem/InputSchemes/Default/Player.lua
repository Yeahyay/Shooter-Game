

local InputScheme = coreUtil.requireEnv("src/ECS/systems/InputSystem/InputScheme")
local InputContext = coreUtil.requireEnv("src/ECS/systems/InputSystem/InputContext")

local defaultPlayerScheme = InputScheme("DefaultPlayer")

local triggerTypeConstant = TriggerTypeEnum.constant.Value
local triggerTypeStart = TriggerTypeEnum.start.Value
local triggerTypeStop = TriggerTypeEnum.stop.Value

-- DEFAULT
local context = InputContext("Default")
-- KEYBOARD
do
	local keyInputValueType = InputValueTypeEnum.number.Value
	local keyInputType = InputTypeEnum.key.Value

	context:addInputGroup(InputGroup(InputGroupsEnum.key.Value)
		:addInput(Input(keyInputType, keyInputValueType, "w", "up", triggerTypeConstant, 0))
		:addInput(Input(keyInputType, keyInputValueType, "a", "left", triggerTypeConstant, 0))
		:addInput(Input(keyInputType, keyInputValueType, "s", "down", triggerTypeConstant, 0))
		:addInput(Input(keyInputType, keyInputValueType, "d", "right", triggerTypeConstant, 0))
		-- :addInput(Input(keyInputType, keyInputValueType, "p", "respawn", triggerTypeConstant, 0))
	)
end
-- MOUSE WHEEL
-- do
-- 	local mouseWheelInputValueType = InputValueTypeEnum.vector2.Value
-- 	local mouseWheelInputType = InputTypeEnum.mouseWheel.Value
-- 	local mouseWheelInputGroup = InputGroup(InputGroupsEnum.mouseWheel.Value)
-- 		:addInput(Input(mouseWheelInputType, mouseWheelInputValueType, "up", "wheelUp", triggerTypeConstant, 0))
-- 		:addInput(Input(mouseWheelInputType, mouseWheelInputValueType, "down", "wheelDown", triggerTypeConstant, 0))
-- 		:addInput(Input(mouseWheelInputType, mouseWheelInputValueType, "left", "wheelLeft", triggerTypeConstant, 0))
-- 		:addInput(Input(mouseWheelInputType, mouseWheelInputValueType, "right", "wheelRight", triggerTypeConstant, 0))
-- end
defaultPlayerScheme:addContext(context)
defaultPlayerScheme:push("Default")

return defaultPlayerScheme
