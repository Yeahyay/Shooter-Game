local graphics = {
	depends = {"Math", "Core.Paths"}
}

local ffi = require("ffi")

function graphics:load()
	require("love.window")
	require("love.graphics")

	local Paths = Feint.Core.Paths

	Paths.Add("Graphics", Paths.Modules .. "graphics")

	-- local width, height, flags = love.window.getMode() -- luacheck: ignore
	local screenHeight = 720
	local screenWidth = screenHeight * (16 / 9)
	local renderHeight = 720
	local renderWidth = renderHeight * (16 / 9)
	self.ScreenSize = Feint.Math.Vec2.new(screenWidth, screenHeight)
	self.ScreenAspectRatio = 16 / 9
	self.RenderSize = Feint.Math.Vec2.new(renderWidth, renderHeight)
	self.RenderAspectRatio = 16 / 9
	self.RenderScale = Feint.Math.Vec2.new(1, 1)
	self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
	self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize

	local Slab = require(Paths.Lib .. "Slab-0_6_3.Slab")
	self.UI = {}
	self.UI.Immediate = setmetatable({}, {
		__index = Slab
	})

	local interpolate = 0

	local TEXTURE_ASSETS = {}
	local SPRITES_PATH = Paths.SlashDelimited(Paths.Assets .. "sprites")
	for _, file in pairs(love.filesystem.getDirectoryItems(SPRITES_PATH)) do
		if file:find(".png") then
			local path = SPRITES_PATH .. "/" .. file
			local image = love.graphics.newImage(path)
			local batch = love.graphics.newSpriteBatch(image, nil, "stream")
			TEXTURE_ASSETS[file] = {image = image, sizeX = image:getWidth(), sizeY = image:getHeight(), batch = batch}
		end
	end

	function self:getTextures()
		return TEXTURE_ASSETS
	end

	self.drawables = {}
	local ID = 0
	function self:addPrimitive(type, ...)
		local id = -1
		if type == "rect" then
			id = self:addRectangle(...)
		end
		return id
	end

	function self:remove(id)

	end

	love.graphics.setLineStyle("rough")
	love.graphics.setDefaultFilter("nearest", "nearest", 16)

	love.window.updateMode(self.ScreenSize.x, self.ScreenSize.y, {
		fullscreen = false,
		fullscreentype = "desktop",
		vsync = false,
		msaa = 0,
		resizable = true,
		borderless = false,
		centered = true,
		display = 1,
		minwidth = 1,
		minheight = 1,
		highdpi = false,
		x = nil,
		y = nil,
	})

	function self:setRenderResolution(x, y)
		self.RenderSize.x = x
		self.RenderSize.y = y
		self.RenderAspectRatio = x / y
		self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
		self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize
	end
	function self:setScreenResolution(x, y)
		self.ScreenSize.x = x
		self.ScreenSize.y = y
		self.ScreenAspectRatio = x / y
		self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
		self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize
	end

	function self:modify(name, len, id, x, y, r, width, height)
		-- self.drawables[id].x = x
		-- self.drawables[id].y = -y -- self.RenderSize.y - y
		-- self.drawables[id].r = r
		-- self.drawables[id].width = width
		-- self.drawables[id].height = height
		-- something something check if on screen


		-- local drawCall = self.drawables[id]
		-- local interX, interY = drawCall[ENUM_INTERPOLATE_X], drawCall[ENUM_INTERPOLATE_Y]
		local transformX, transformY = x, -y--drawCall.x,  drawCall.y

		-- local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)

		local dx = transformX
		local dy = transformY

		-- print("id: " .. id, TEXTURE_ASSETS[ffi.string(name, len)], ffi.string(name, len))
		local drawable = TEXTURE_ASSETS[ffi.string(name, len)]
		local batch = drawable.batch
		batch:set(id, math.floor(dx), math.floor(dy), r,
			width, height,
			drawable.sizeX, drawable.sizeY)
		-- love.graphics.draw(drawable.image, dx, dy, r, 1, 1)
	end

	function self:addRectangle(name, len, x, y, r, width, height)
		local id = TEXTURE_ASSETS[ffi.string(name, len)].batch:add(x, y, r, width, height)
		self.drawables[id] = {x = x, y = y, r = r, width = width, height = height}
		return id
	end

	function self:clear()

	end
	function self:update()
	end

	local canvas = love.graphics.newCanvas(self.RenderSize.x, self.RenderSize.y, {msaa = 0})
	function self:draw()
		love.graphics.setCanvas(canvas)
		love.graphics.clear()

		love.graphics.setColor(0.35, 0.35, 0.35, 1)
		love.graphics.rectangle("fill", 0, 0, self.RenderSize.x, self.RenderSize.y)
		love.graphics.setColor(0.25, 0.25, 0.25, 1)
		love.graphics.rectangle("fill",
			self.RenderSize.x / 4, self.RenderSize.y / 4, self.RenderSize.x / 2, self.RenderSize.y / 2
		)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.push()
			love.graphics.scale(self.RenderScale.x, self.RenderScale.y)
			love.graphics.translate(self.RenderSize.x / 2, self.RenderSize.y / 2)
			-- love.graphics.setWireframe(true)

			for k, v in pairs(TEXTURE_ASSETS) do
				love.graphics.draw(v.batch, 0, 0, 0, 1, 1)
			end

		love.graphics.pop()
		love.graphics.setCanvas()

		local sx = self.RenderToScreenRatio.x / self.RenderScale.x
		local sy = self.RenderToScreenRatio.y / self.RenderScale.y
		love.graphics.draw(canvas, 0, 0, 0, sx, sy, 0, 0)
	end

	function self:updateInterpolate(value)
		if graphics.interOn then
			interpolate = math.sqrt(value / Feint.Run.rate, 2)
		else
			interpolate = 0
		end
	end

	function self:getInterpolate()
		return interpolate
	end

	function self:getNewID()
		ID = ID + 1
		return ID
	end
end

return graphics
