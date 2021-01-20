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

	function private.mousepressed(x, y, button)
		local mouse = self.Mouse
		mouse.ClickPosition = mouse.Position
		mouse.ClickPositionWorld = mouse.PositionWorld
	end
	function private.mousemoved(x, y, dx, dy)
		local mouse = self.Mouse
		mouse.PositionRawOld = mouse.PositionRaw
		mouse.PositionRaw.x, mouse.PositionRaw.y = x, Feint.Core.Graphics.ScreenSize.y - y
		mouse.PositionRaw = mouse.PositionRaw % Feint.Core.Graphics.ScreenToRenderRatio
		mouse.PositionOld = mouse.Position
		mouse.Position = mouse.PositionRaw - Feint.Core.Graphics.RenderSize / 2

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
end

return input
