local graphics = {
	depends = {"Math", "Core.Paths"},
	isThreadSafe = false,
	Public = {}
}

local ffi = require("ffi")

function graphics:load(isThread)
	if not isThread then
		require("love.window")
	end
	-- require("love.graphics")

	local Paths = Feint.Core.Paths

	Paths:Add("Graphics", Paths.Core .. "Graphics")
	local BatchSet = require(Paths.Graphics .. "batchSet")


	local Slab = require(Paths.Lib .. "Slab-0_6_3.Slab")
	self.UI = {}
	self.UI.Immediate = setmetatable({}, {
		__index = Slab
	})

	local resolution = require(Paths.Graphics .. "resolution")
	resolution:load(isThread)

	setmetatable(self, {
		__index = resolution
	})

	local interpolate = 0

	local TEXTURE_ASSETS = {}
	local SPRITES_PATH = Paths:SlashDelimited(Paths.Assets .. "sprites")
	if not isThread then
		for _, file in pairs(love.filesystem.getDirectoryItems(SPRITES_PATH)) do
			if file:find(".png") then
				local path = SPRITES_PATH .. "/" .. file
				if not love.filesystem.getInfo(path).exists then
					path = SPRITES_PATH .. "/" .. "Test Texture 1.png"
				end
				local image = love.graphics.newImage(path)
				-- local batch = love.graphics.newSpriteBatch(image, nil, "stream")
				-- TEXTURE_ASSETS[file] = {image = image, sizeX = image:getWidth(), sizeY = image:getHeight(), batches = {batch}}
				TEXTURE_ASSETS[file] = BatchSet:new(image)
			end
		end
	end

	function self:getTextures()
		return TEXTURE_ASSETS
	end

	self.canvas = nil
	self.canvas2 = nil
	if not isThread then
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

		self.canvas = love.graphics.newCanvas(self.RenderSize.x, self.RenderSize.y, {msaa = 0})
		self.canvas2 = love.graphics.newCanvas(self.RenderSize.x, self.RenderSize.y, {msaa = 0})
	end

	function self:modify(name, id, x, y, r, width, height)

		-- local drawCall = self.drawables[id]
		-- local interX, interY = drawCall[ENUM_INTERPOLATE_X], drawCall[ENUM_INTERPOLATE_Y]
		local transformX, transformY = x, -y--drawCall.x,  drawCall.y

		-- local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)

		local dx = math.floor(transformX)
		local dy = math.floor(transformY)

		local string = ffi.string(name.string, #name) -- VERY SLOW
		local batchSet = TEXTURE_ASSETS[string]
		batchSet:modifySprite(id, x, y, r, width, height)
		-- batch:set(id, dx, dy, r,
		-- 	width, height,
		-- 	drawable.sizeX / 2, drawable.sizeY / 2
		-- )
		-- love.graphics.draw(drawable.image, dx, dy, r, width, height, drawable.sizeX, drawable.sizeY)
	end

	function self:addRectangle(name, x, y, r, width, height, ox, oy)
		local string = ffi.string(name.string, #name) -- VERY SLOW
		-- assert(string, "string is broken")
		-- local id = TEXTURE_ASSETS[string].batch:add(x, y, r, width, height, width / 2, height / 2)
		local id = TEXTURE_ASSETS[string]:addSprite(x, y, r, width, height, ox, oy)
		-- self.drawables[id] = {x = x, y = y, r = r, width = width, height = height}
		return id
	end

	function self:clear()

	end
	function self:update()
		-- for k, v in pairs(TEXTURE_ASSETS) do
		-- 	v.batch:flush()
		-- end
	end

	function self:draw()
		love.graphics.setCanvas(self.canvas)
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

			for k, textureAsset in pairs(TEXTURE_ASSETS) do
				textureAsset:draw()
				-- local batches = textureAsset.batches
				-- for i = 1, #batches, 1 do
				-- 	local batch = batches[i]
				-- 	-- batch:draw()
				-- 	love.graphics.draw(batch, 0, 0, 0, 1, 1)
				-- end
			end

		love.graphics.pop()
		love.graphics.setCanvas()

		local sx = self.RenderToScreenRatio.x / self.RenderScale.x
		local sy = self.RenderToScreenRatio.y / self.RenderScale.y
		love.graphics.draw(self.canvas, 0, 0, 0, sx, sy, 0, 0)
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
end

return graphics
