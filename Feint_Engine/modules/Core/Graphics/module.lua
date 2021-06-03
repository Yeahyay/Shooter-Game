local graphics = {
	depends = {"Math", "Core.Paths", "Core.AssetManager"},
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


	local Slab = require(Paths.Lib .. "Slab-0_7_2.Slab")
	self.UI = {}
	self.UI.Immediate = setmetatable({}, {
		__index = Slab
	})

	local resolution = require(Paths.Graphics .. "resolution")
	resolution:load(isThread)

	setmetatable(self, {
		__index = resolution
	})

	local RenderSize = Feint.Core.Graphics.RenderSize
	self.Camera = {
		x = 0; y = 0; zoom = 0;
		tx = 0; ty = 0; tzoom = 0;
		setPosition = function(self, x, y)
			self.tx = x
			self.ty = y
		end;
		setRawPosition = function(self, x, y)
			self.x = x
			self.y = y
		end;
		setZoom = function(self, zoom)
			self.tzoom = zoom
		end;
		setRawZoom = function(self, zoom)
			self.zoom = zoom
		end;
		update = function(self)
			self.x = self.x + (self.tx - self.x) * 0.1
			self.y = self.y + (self.ty - self.y) * 0.1
		end;
		getMousePosition = function(self)
			return Feint.Core.Input.Mouse.Position + Feint.Math.Vec2(self.x, self.y)
		end;
		getScreenBounds = function(self)
			return self.x - RenderSize.x * 0.5, self.y + RenderSize.y * 0.5, self.x + RenderSize.x * 0.5, self.y - RenderSize.y * 0.5
		end
	}

	local interpolate = 0

	local TEXTURE_ASSETS = {}
	local SPRITES_PATH = Paths:SlashDelimited(Paths.Assets .. "sprites")
	if not isThread then
		for _, filename in pairs(love.filesystem.getDirectoryItems(SPRITES_PATH)) do
			if filename:find(".png") then
				local path = SPRITES_PATH .. "/" .. filename
				if not love.filesystem.getInfo(path).exists then
					path = SPRITES_PATH .. "/" .. "Test Texture 1.png"
				end
				local image = love.graphics.newImage(path)
				-- local batch = love.graphics.newSpriteBatch(image, nil, "stream")
				-- TEXTURE_ASSETS[file] = {image = image, sizeX = image:getWidth(), sizeY = image:getHeight(), batches = {batch}}
				Feint.Core.AssetManager:registerAsset(image, filename, "image")
				Feint.Core.AssetManager:registerAsset(BatchSet:new(image), filename, "batchSet")
				TEXTURE_ASSETS[filename] = BatchSet:new(image)
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
			-- display = 1,
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
		-- local transformX, transformY = x, -y--drawCall.x,  drawCall.y

		-- local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)

		-- local dx = math.floor(transformX)
		-- local dy = math.floor(transformY)

		-- print("skdmdl;k")
		local string = ffi.string(name.string, #name) -- VERY SLOW
		-- print("skdmdl;k")
		local batchSet = TEXTURE_ASSETS[string]
		-- print(string)
		batchSet:modifySprite(id, x, -y, r, width, height)
		-- batch:set(id, dx, dy, r,
		-- 	width, height,
		-- 	drawable.sizeX * 0.5, drawable.sizeY * 0.5
		-- )
		-- love.graphics.draw(drawable.image, dx, dy, r, width, height, drawable.sizeX, drawable.sizeY)
	end
	function self:setVisible(name, id, visible)
		local string = ffi.string(name.string, #name) -- VERY SLOW
		-- print("skdmdl;k")
		local batchSet = TEXTURE_ASSETS[string]
		-- print(string)
		batchSet:setVisible(id, visible)
	end

	function self:addRectangle(name, x, y, r, width, height, ox, oy)
		assert(string, "no name given", 2)
		-- local string = ffi.string(name, #name)
		local string = ffi.string(name.string, #name) -- VERY SLOW
		-- assert(string, "string is broken")
		-- local id = TEXTURE_ASSETS[string].batch:add(x, y, r, width, height, width * 0.5, height * 0.5)
		local id = TEXTURE_ASSETS[string]:addSprite(x, y, r, width, height, ox, oy)
		-- self.drawables[id] = {x = x, y = y, r = r, width = width, height = height}
		return id
	end

	function self:clear()

	end
	function self:update()
		self.Camera:update()
		-- for k, v in pairs(TEXTURE_ASSETS) do
		-- 	v.batch:flush()
		-- end
	end

	self.textQueue = {}
	self.textQueue.size = 0
	function self:queueText(string, x, y, r, sx, sy, ox, oy)
		self.textQueue.size = self.textQueue.size + 1
		local item = self.textQueue[self.textQueue.size]
		if not item then
			item = {}
			self.textQueue[self.textQueue.size] = item
		end
		-- print(item, self.textQueue[self.textQueue.size])

		item[1] = string
		item[2] = x
		item[3] = y
		item[4] = r
		item[5] = sx
		item[6] = sy
		item[7] = ox
		item[8] = oy
		item[9] = 0
		item[10] = 0
	end

	function self:resetQueues()
		self.textQueue.size = 0
	end

	function self:drawText()
		love.graphics.setFont(Feint.Core.AssetManager:requestAsset("Default Font", Feint.Core.AssetManager.FONT))
		for i = 1, self.textQueue.size, 1 do
			local textData = self.textQueue[i]
			-- print(i, unpack(textData))
			love.graphics.print(textData[1], textData[2], -textData[3], textData[4], textData[5], textData[6], textData[7], textData[8], textData[9], textData[10])
		end
	end

	function self:draw()
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear()

		love.graphics.setColor(0.35, 0.35, 0.35, 1)
		love.graphics.rectangle("fill", 0, 0, self.RenderSize.x, self.RenderSize.y)
		love.graphics.setColor(0.25, 0.25, 0.25, 1)
		love.graphics.rectangle("fill",
			self.RenderSize.x * 0.25, self.RenderSize.y * 0.25, self.RenderSize.x * 0.5, self.RenderSize.y * 0.5
		)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.push()
			love.graphics.translate(-self.Camera.x, self.Camera.y)
			love.graphics.scale(self.RenderScale.x, self.RenderScale.y)
			love.graphics.translate(self.RenderSize.x * 0.5, self.RenderSize.y * 0.5)
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

			self:drawText()

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
