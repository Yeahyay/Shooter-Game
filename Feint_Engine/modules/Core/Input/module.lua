local input = {
	depends = {"Math"}
}

local private = {}

setmetatable(input, {
	__index = private,
	-- __newindex = private
})

function input:load()
	Feint.Core.Paths.Add("Input", Feint.Core.Paths.Modules .."input")

	self.mouse = {}
	self.mouse.ClickPosition = Feint.Math.Vec2(0, 0)
	self.mouse.ClickPositionWorld = Feint.Math.Vec2(0, 0)

	self.mouse.ReleasePosition = Feint.Math.Vec2(0, 0)
	self.mouse.ReleasePositionWorld = Feint.Math.Vec2(0, 0)

	self.mouse.PositionRawOld = Feint.Math.Vec2(0, 0)
	self.mouse.PositionRaw = Feint.Math.Vec2(0, 0)
	self.mouse.PositionOld = Feint.Math.Vec2(0, 0)
	self.mouse.Position = Feint.Math.Vec2(0, 0)

	-- mouse.PositionWorld = Vec3.new()
	-- mouse.PositionWorldOld = Vec3.new()

	self.mouse.PositionUnitOld = Feint.Math.Vec2(0, 0)
	self.mouse.PositionUnit = Feint.Math.Vec2(0, 0)

	self.mouse.PositionDeltaOld = Feint.Math.Vec2(0, 0)
	self.mouse.PositionDelta = Feint.Math.Vec2(0, 0)


	function private.mousepressed(x, y, button)
		local mouse = self.mouse
		mouse.ClickPosition = mouse.Position
		mouse.ClickPositionWorld = mouse.PositionWorld
	end
	function private.mousemoved(x, y, dx, dy)
		local mouse = self.mouse
		mouse.PositionRawOld = mouse.PositionRaw
		mouse.PositionRaw.x, mouse.PositionRaw.y = x, Feint.Graphics.ScreenSize.y - y
		mouse.PositionRaw = mouse.PositionRaw % Feint.Graphics.ScreenToRenderRatio
		mouse.PositionOld = mouse.Position
		mouse.Position = mouse.PositionRaw - Feint.Graphics.RenderSize / 2

		mouse.PositionUnitOld = mouse.PositionUnit
		mouse.PositionUnit = mouse.Position / Feint.Graphics.RenderSize

		mouse.PositionDeltaOld = mouse.PositionDelta
		-- mouse.PositionDelta = mouse.Position - mouse.PositionOld
		mouse.PositionDelta = Feint.Math.Vec2(dx, dy)
	end
	function private.mousereleased(x, y, button)
		local mouse = self.mouse
		mouse.ReleasePosition = mouse.Position
		mouse.ReleasePositionWorld = mouse.PositionWorld
	end
end

return input
