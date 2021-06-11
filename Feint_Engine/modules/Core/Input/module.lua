local input = {
	depends = {"Math"}
}

local private = {}

setmetatable(input, {
	__index = private,
	-- __newindex = private
})

function input:load()
	Feint.Core.Paths:Add("Input", Feint.Core.Paths.Modules .."input")

	self.Mouse = {}
	self.Mouse.ClickPosition = Feint.Math.Vec2(0, 0)
	self.Mouse.ClickPositionWorld = Feint.Math.Vec2(0, 0)

	self.Mouse.ReleasePosition = Feint.Math.Vec2(0, 0)
	self.Mouse.ReleasePositionWorld = Feint.Math.Vec2(0, 0)

	self.Mouse.PositionAbsoluteOld = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionAbsolute = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionRawOld = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionRaw = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionOld = Feint.Math.Vec2(0, 0)
	self.Mouse.Position = Feint.Math.Vec2(0, 0)

	-- mouse.PositionWorld = Vec3.new()
	-- mouse.PositionWorldOld = Vec3.new()

	self.Mouse.PositionUnitOld = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionUnit = Feint.Math.Vec2(0, 0)

	self.Mouse.PositionNormalizedOld = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionNormalized = Feint.Math.Vec2(0, 0)

	self.Mouse.PositionDeltaOld = Feint.Math.Vec2(0, 0)
	self.Mouse.PositionDelta = Feint.Math.Vec2(0, 0)

	self.Mouse.ObjectSelected = false
	self.Mouse.ObjectHovered = false

	function private.mousepressed(x, y, button)
		local mouse = self.Mouse
		mouse.ClickPosition = mouse.Position
		mouse.ClickPositionWorld = mouse.PositionWorld
		mouse.ObjectSelected = mouse.ObjectHovered or mouse.ObjectSelected
	end
	function private.mousemoved(x, y, dx, dy)
		local mouse = self.Mouse
		mouse.PositionAbsoluteOld = mouse.PositionAbsolute
		mouse.PositionAbsolute.x, mouse.PositionAbsolute.y = x, - y
		-- mouse.PositionAbsolute = mouse.PositionAbsolute % Feint.Core.Graphics.ScreenToRenderRatio
			-- local ratio = Feint.Core.Graphics.ScreenToRenderRatio
			-- local screenSize = Feint.Core.Graphics.ScreenSize
			-- local position = Feint.Math.Vec2(mouse.PositionRaw.x * 1 / ratio.x, mouse.PositionRaw.y * 1 / ratio.y)

		mouse.PositionRawOld = mouse.PositionRaw
		mouse.PositionRaw.x, mouse.PositionRaw.y = x, Feint.Core.Graphics.ScreenSize.y - y
		mouse.PositionRaw = mouse.PositionRaw % Feint.Core.Graphics.ScreenToRenderRatio

		mouse.PositionOld = mouse.Position
		mouse.Position = mouse.PositionRaw - Feint.Core.Graphics.RenderSize * 0.5


		mouse.PositionUnitOld = mouse.PositionUnit
		mouse.PositionUnit = mouse.Position * 2 / Feint.Core.Graphics.RenderSize

		mouse.PositionNormalizedOld = mouse.PositionNormalized
		mouse.PositionNormalized = mouse.Position / Feint.Core.Graphics.RenderSize + Feint.Math.Vec2(0.5, 0.5)

		mouse.PositionDeltaOld = mouse.PositionDelta
		-- mouse.PositionDelta = mouse.Position - mouse.PositionOld
		mouse.PositionDelta = Feint.Math.Vec2(dx, dy)
	end
	function private.mousereleased(x, y, button)
		local mouse = self.Mouse
		mouse.ReleasePosition = mouse.Position
		mouse.ReleasePositionWorld = mouse.PositionWorld
	end

	self.Gamepad = {}
	self.joysticks = {}
	function self:joystickadded(joystick)
		local mappingString = joystick:getGamepadMappingString()
		local id = joystick:getID()
		self.joysticks[id] = joystick

		local gamepad = {
			buttons = {}, axes = {}, hats = {}, mappingIndex = {}
		}
		self.Gamepad[id] = gamepad
		-- for i = 1, joystick:getButtonCount(), 1 do
			-- gamepad.axes[#gamepad.axes + 1] =
		-- end
		-- print(mappingString:gsub("(,)", "%1\n"))
		for name, input, type, number in mappingString:gmatch("(%a+):((%a+)([%d%p]+)),") do
			-- print(name, type, number, input)
			gamepad.mappingIndex[type] = name
			gamepad.mappingIndex[name] = type
			if type == "a" then
				gamepad.axes[name] = 0
			elseif type == "b" then
				gamepad.buttons[name] = false
			elseif type == "h" then
				gamepad.hats[name] = false
			end
		end
	end
	function self:gamepadChanged(joystick)
		-- local id = joystick:getID()
		-- for _, buttonGroup in pairs(self.Gamepad[id]) do
		-- 	for k, v in pairs(buttonGroup) do
		-- 		print(k, v)
		-- 	end
		-- end
	end
	function self:gamepadaxis(joystick, axis, value)
		local id = joystick:getID()
		self.Gamepad[id].axes[axis] = value
		-- print(axis, value)
		self:gamepadChanged(joystick)
	end
	function self:gamepadpressed(joystick, button)
		local id = joystick:getID()
		local gamepad = self.Gamepad[id]
		-- print(button)
		if gamepad.mappingIndex[button] == "h" then
			gamepad.hats[button] = true
		else
			gamepad.buttons[button] = true
		end
		self:gamepadChanged(joystick)
	end
	function self:gamepadreleased(joystick, button)
		local id = joystick:getID()
		local gamepad = self.Gamepad[id]
		if gamepad.mappingIndex[button] == "h" then
			gamepad.hats[button] = false
		else
			gamepad.buttons[button] = false
		end
		self:gamepadChanged(joystick)
	end
	function self:joystickhat(joystick, hat, direction)
		-- local id = joystick:getID()
		-- -- self.Gamepad[id].axes[button] = value
		-- self:gamepadChanged(joystick)
	end
	function self:joystickaxis(joystick, axis, value)
		-- local id = joystick:getID()
		-- -- self.Gamepad[id].axes[button] = value
		-- self:gamepadChanged(joystick)
	end
	function self:joystickpressed(joystick, button)
		-- local id = joystick:getID()
		-- self.Gamepad[id].buttons[button] = true
		-- self:gamepadChanged(joystick)
	end
	function self:joystickreleased(joystick, button)
		-- local id = joystick:getID()
		-- self.Gamepad[id].buttons[button] = false
		-- self:gamepadChanged(joystick)
		-- print("kml;kl")
	end
end

return input
