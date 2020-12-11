globalInputScheme = InputScheme("Global")

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
			:addInput(Input(keyInputType, keyInputValueType, "f5", "save game", triggerTypeStart, 0))
			:addInput(Input(keyInputType, keyInputValueType, "f6", "SWITCH MODE", triggerTypeStart, 0))
			:addInput(Input(keyInputType, keyInputValueType, "f9", "load game", triggerTypeStart, 0))
		)
	end
	-- MOUSE	
	do
		local mouseInputValueType = InputValueTypeEnum.vector2.Value
		local mouseInputType = InputTypeEnum.mouse.Value

		context:addInputGroup(InputGroup(InputGroupsEnum.mouse.Value)
			:addInput(Input(mouseInputType, mouseInputValueType, "m1", "mouseLeft", triggerTypeConstant, 0))
			:addInput(Input(mouseInputType, mouseInputValueType, "m2", "mouseRight", triggerTypeConstant, 0))
		)
	end
	globalInputScheme:addContext(context)
	globalInputScheme:push("Default")
