-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

if Feint.ECS.FFI_OPTIMIZATIONS then
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Renderer", {
		visible = true,
		texture = "Test Texture 1.png",
		id = -1--Feint.Util.UUID.new()
	}))
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Transform", {
		x = 0,						-- 0
		y = 0,						-- 1
		angle = 0,					-- 2
		sizeX = 32,					-- 3
		sizeY = 32,					-- 4
		scaleX = 32,				-- 5
		scaleY = 32,				-- 6
		trueSizeX = 32 / 32,		-- 7
		trueSizeY = 32 / 32,		-- 8
	}))
else
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Renderer", {
		{visible = true},
	}))
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Transform", {
		{x = 0},						-- 0
		{y = 0},						-- 1
		{angle = 0},				-- 2
		{sizeX = 32},				-- 3
		{sizeY = 32},				-- 4
		{scaleX = 16},				-- 5
		{scaleY = 16},				-- 6
		{trueSizeX = 16 / 32},	-- 7
		{trueSizeY = 16 / 32},	-- 8
	}))
end

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

local fmath = Feint.Math
local random2 = fmath.random2

local ffi = require("ffi")
function RenderSystem:start()
	-- print(os.capture("wmic cpu list full"), "as kdnklnsd")
	-- for k, v in pairs(love.graphics.getSystemLimits()) do
	-- 	print(k, v)
	-- end
	-- print()
	-- for k, v in pairs(love.graphics.getSupported()) do
	-- 	print(k, v)
	-- end

	local world = World.DefaultWorld
	local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
	local archetype = self.EntityManager:newArchetype{Renderer, Transform}
	for i = 1, 1000, 1 do
		self.EntityManager:CreateEntity(archetype)
	end

	local r = {}
	for k, v in pairs(Feint.Core.Graphics:getTextures()) do
		r[#r + 1] = k
		-- print(#r, r[#r])
	end

	local graphics = Feint.Core.Graphics
	if Feint.ECS.FFI_OPTIMIZATIONS then
		self.EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
			-- print(Data[Entity], Entity)
			Transform.x = random2(Feint.Core.Graphics.RenderSize.x / 2)
			Transform.y = random2(-Feint.Core.Graphics.RenderSize.y / 2, Feint.Core.Graphics.RenderSize.y / 2 - 300)
			Transform.trueSizeX = Transform.scaleX / Transform.sizeX
			Transform.trueSizeY = Transform.scaleY / Transform.sizeY

			local trueSizeX = Transform.trueSizeX
			local trueSizeY = Transform.trueSizeY
			-- local rand = math.floor(random2(1, 9))
			-- Renderer.texture = ffi.cast("uint8_t*", r[rand])
			-- Renderer.textureSize = r[rand]:len()
			-- print(r[rand]:len())
			-- print(Feint.Core.Graphics:getTextures()["Test Texture 1.png"])
			Renderer.texture = Feint.FFI.cstring("walking1.png")
			Renderer.id = graphics:addRectangle(
				Renderer.texture,-- Renderer.textureLength,
				Transform.x - trueSizeX / 2, Transform.y - trueSizeY / 2, Transform.angle, trueSizeX, trueSizeY
			)
		end)
	else
		self.EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
			-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
			-- local x = Data[Transform]
			-- local y = Data[Transform + 1]
			local x = random2(Feint.Core.Graphics.RenderSize.x / 2)
			local y = random2(-Feint.Core.Graphics.RenderSize.y / 2, Feint.Core.Graphics.RenderSize.y / 2 - 300)
			local angle = Data[Transform + 2]
			local sizeX = Data[Transform + 3]
			local sizeY = Data[Transform + 4]
			local scaleX = Data[Transform + 5]
			local scaleY = Data[Transform + 6]
			local trueSizeX = scaleX / sizeX
			local trueSizeY = scaleY / sizeY

			Data[Transform] = x
			Data[Transform + 1] = y
			Data[Transform + 7] = trueSizeX
			Data[Transform + 8] = trueSizeY

			-- Renderer.id = graphics:addRectangle(
			-- 	x - trueSizeX / 2, y - trueSizeY / 2, angle, trueSizeX, trueSizeY
			-- )
		end)
	end
end

-- local input = Feint.Core.Input
-- local px, py = 0, 0
-- local lx, ly = 0, 0
function RenderSystem:update(dt)
	-- do
	-- 	lx, ly = px, py
	-- 	px, py = input.mouse.Position.x, input.mouse.Position.y
	-- 	local angle = Feint.Core.Time:getTime()
	-- 	local rect = Feint.Core.Graphics.rectangleInt
	-- 	rect(lx, ly, angle, px, py, angle, 1, 1)
	-- 	local rect = Feint.Core.Graphics.rectangle
	-- 	rect(px, py, angle, 1, 1)
	-- end

	local sin, cos, pi = math.sin, math.cos, math.pi
	local graphics = Feint.Core.Graphics
	local time = Feint.Core.Time:getTime()
	local oscillate = Feint.Math.oscillateManualSigned
	-- print("time", time)
	for i = 1, 1, 1 do
		if Feint.ECS.FFI_OPTIMIZATIONS then
			self.EntityManager:forEach("main", function(Data, Entity, Renderer, Transform)
				Transform.angle = (time + Entity / 10) * pi -- + Entity * 6
				local offsetX = oscillate(time, 50, 2, Entity)
				local offsetY = oscillate(time, 50, 2, (Entity * Entity) % (2 * math.pi))

				local trueSizeX = Transform.trueSizeX
				local trueSizeY = Transform.trueSizeY

				-- oscillate(trueSizeX, trueSizeY, offsetX, offsetY)
				graphics:modify(
					Renderer.texture,-- Renderer.textureLength,
					Renderer.id,
					offsetX + Transform.x - trueSizeX / 2,
					offsetY + Transform.y - trueSizeY / 2,
					Transform.angle, trueSizeX, trueSizeY
				)
			end)
		else
			self.EntityManager:forEach("main", function(Data, Entity, Renderer, Transform)
				local x = Data[Transform]
				local y = Data[Transform + 1]
				local angle = Data[Transform + 2]
				-- local trueSizeX = Data[Transform + 7]
				-- local trueSizeY = Data[Transform + 8]

				-- rect(x - trueSizeX / 2, y - trueSizeY / 2, angle, trueSizeX, trueSizeY)

				angle = angle + 1 / 60 * pi + Entity

				Data[Transform + 2] = angle
				Data[Transform] = x + sin(time * 2 + Entity * 0.25) * 0.5
				Data[Transform + 1] = y + cos(time * 2 + Entity * 0.25) * 0.5
			end)
		end
	end
end

return RenderSystem
