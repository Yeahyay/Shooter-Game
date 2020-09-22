debugInputScheme = InputScheme("Debug")

local triggerTypeConstant = TriggerTypeEnum.constant.Value
local triggerTypeStart = TriggerTypeEnum.start.Value
local triggerTypeStop = TriggerTypeEnum.stop.Value

-- DEFAULT
local context = InputContext("Default")
	-- KEYBOARD
	do
		local keyInputValueType = InputValueTypeEnum.number.Value
		local keyInputType = InputTypeEnum.key.Value

		context:addInputGroup(
			InputGroup(InputGroupsEnum.key.Value)
			:addInput(Input(keyInputType, keyInputValueType, "f5", "SWITCH MODE", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "f6", "save game", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "f9", "load game", triggerTypeConstant, 0))
		)
	end
	debugInputScheme:addContext(context)
	debugInputScheme:push("Default")
