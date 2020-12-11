defaultEditorScheme = InputScheme("DefaultEditor")

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
			:addInput(Input(keyInputType, keyInputValueType, "w", "cameraUp", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "a", "cameraLeft", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "s", "cameraDown", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "d", "cameraRight", triggerTypeConstant, 0))
			:addInput(Input(keyInputType, keyInputValueType, "p", "playerRespawn", triggerTypeStart, 0))
			:addInput(Input(keyInputType, keyInputValueType, "delete", "remove", triggerTypeStart, 0))
			-- :addInput(Input(keyInputType, keyInputValueType, "z", "CONTEXT", triggerTypeStart, 0))
			:addInput(Input(keyInputType, keyInputValueType, "q", "build", triggerTypeStart, 0))
		)
	end

	do
		local mouseInputValueType = InputValueTypeEnum.vector2.Value
		local mouseInputType = InputTypeEnum.mouse.Value

		context:addInputGroup(InputGroup(InputGroupsEnum.mouse.Value)
			:addInput(Input(mouseInputType, mouseInputValueType, "m1", "mouseLeft", triggerTypeConstant, 0))
			:addInput(Input(mouseInputType, mouseInputValueType, "m2", "mouseRight", triggerTypeConstant, 0)))
	end

	defaultEditorScheme:addContext(context)
	defaultEditorScheme:push("Default")

-- OBJECT SELECTION
local context = InputContext("Selecting")
	-- MOUSE
	do
		local mouseInputValueType = InputValueTypeEnum.vector2.Value
		local mouseInputType = InputTypeEnum.mouse.Value

		context:addInputGroup(InputGroup(InputGroupsEnum.mouse.Value)
			:addInput(Input(mouseInputType, mouseInputValueType, "m1", "drag", triggerTypeConstant, 0))
			:addInput(Input(mouseInputType, mouseInputValueType, "m2", "delete", triggerTypeStart, 0))
		)
	end
	defaultEditorScheme:addContext(context)
	-- defaultEditorScheme:push("Selecting")
