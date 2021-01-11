local graphics = {
	depends = {"Math", "Core.Paths"},
	Public = {}
}

local ENV = getfenv(1)

-- setmetatable(graphics, {
-- 	__index = function(t, k, v)
-- 		if not rawget(t, "Public")[k] and getfenv(1) ~= ENV then
-- 			error("Attmept to access private member " .. k, 2)
-- 		end
-- 	end,
-- 	__newindex = function(t, k, v)
-- 		if k == "Public" then
-- 			rawget(t, "Public")[k] = true
-- 		end
-- 		rawset(t, k, v)
-- 	end
-- })

local ffi = require("ffi")

function graphics:load()
	require("love.window")
	require("love.graphics")

	local Paths = Feint.Core.Paths

	Paths.Add("Graphics", Paths.Modules .. "graphics")

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
			if not love.filesystem.getInfo(path).exists then
				path = SPRITES_PATH .. "/" .. "Test Texture 1.png"
			end
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

	local canvas = love.graphics.newCanvas(self.RenderSize.x, self.RenderSize.y, {msaa = 0})
	local canvas2 = love.graphics.newCanvas(self.RenderSize.x, self.RenderSize.y, {msaa = 0})

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
		canvas2 = love.graphics.newCanvas(self.ScreenSize.x, self.ScreenSize.y, {msaa = 0})
	end

	function self:modify(name, id, x, y, r, width, height)
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

		-- local dx = math.floor(transformX)
		-- local dy = math.floor(transformY)

		local drawable = TEXTURE_ASSETS[ffi.string(name.string)]
		-- local batch = drawable.batch
		-- batch:set(id, dx, dy, r,
		-- 	width, height,
		-- 	drawable.sizeX, drawable.sizeY)
		-- love.graphics.draw(drawable.image, dx, dy, r, width, height, drawable.sizeX, drawable.sizeY)
	end

	function self:addRectangle(name, x, y, r, width, height)
		-- local id = TEXTURE_ASSETS[ffi.string(name.string, #name)].batch:add(x, y, r, width, height)
		-- self.drawables[id] = {x = x, y = y, r = r, width = width, height = height}
		return 0--id
	end

	function self:clear()

	end
	function self:update()
	end

	function self:draw()
		love.graphics.setCanvas(canvas2)
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
				love.graphics.draw(v.batch, 0, 200, 0, 1, 1)
			end

		love.graphics.pop()
		love.graphics.setCanvas()
		-- love.graphics.setBlendMode("alpha", "premultiplied")
		-- love.graphics.clear()
		--
		local sx = self.RenderToScreenRatio.x / self.RenderScale.x
		local sy = self.RenderToScreenRatio.y / self.RenderScale.y
		love.graphics.draw(canvas2, 0, (self.ScreenSize.y - self.ScreenSize.y), 0, sx, sy, 0, 0)
		-- love.graphics.rectangle("fill", 200, 200, 200, 200)

		-- love.graphics.setCanvas()
		-- love.graphics.clear()
		-- love.graphics.draw(canvas2, 0, 0, 1, 1, 0, 0)
		-- love.graphics.draw(canvas, 0, 0, 1, 1, 0, 0)
	end

	function self:updateInterpolate(value)
		if self.interOn then
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
