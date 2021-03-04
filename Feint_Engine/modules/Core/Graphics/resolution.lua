local resolution = {}

function resolution:load(isThread)
	-- local width, height, flags = love.window.getMode() -- luacheck: ignore
	local aspectRatio = 16 / 9
	local screenHeight = 720
	local renderHeight = 1080
	local screenWidth = screenHeight * (aspectRatio)
	local renderWidth = renderHeight * (aspectRatio)
	self.ScreenSize = Feint.Math.Vec2.new(screenWidth, screenHeight)
	-- self.TrueScreenSize
	self.ScreenAspectRatio = aspectRatio
	self.RenderSize = Feint.Math.Vec2.new(renderWidth, renderHeight)
	self.RenderAspectRatio = aspectRatio
	self.RenderScale = Feint.Math.Vec2.new(1, 1)
	self.isEnforceRatio = true
	self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
	self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize

	function self:setRenderResolution(x, y)
		self.RenderSize.x = x
		self.RenderSize.y = self.isEnforceRatio and x / self.RenderAspectRatio or y
		self.RenderAspectRatio = self.RenderSize.x / self.RenderSize.y
		self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
		self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize
	end
	function self:setScreenResolution(x, y)
		self.ScreenSize.x = x
		self.ScreenSize.y = self.isEnforceRatio and x / self.ScreenAspectRatio or y
		self.ScreenAspectRatio = self.ScreenSize.x / self.ScreenSize.y
		self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
		self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize
		if not isThread then
			self.canvas2 = love.graphics.newCanvas(self.ScreenSize.x, self.ScreenSize.y, {msaa = 0})
		end
	end
end

return resolution
