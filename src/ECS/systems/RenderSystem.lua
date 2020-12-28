-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

if Feint.ECS.FFI_OPTIMIZATIONS then
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Renderer", {
		visible = true,
		id = Feint.Util.UUID.new()
	}))
	World.DefaultWorld:addComponent(Feint.ECS.Component:new("Transform", {
		x = 0,						-- 0
		y = 0,						-- 1
		angle = 0,					-- 2
		sizeX = 32,					-- 3
		sizeY = 32,					-- 4
		scaleX = 16,				-- 5
		scaleY = 16,				-- 6
		trueSizeX = 16 / 32,		-- 7
		trueSizeY = 16 / 32,		-- 8
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

	local rect = Feint.Core.Graphics.rectangle
	if Feint.ECS.FFI_OPTIMIZATIONS then
		self.EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
			-- print(Data[Entity], Entity)
			Transform.x = random2(Feint.Core.Graphics.RenderSize.x / 2)
			Transform.y = random2(-Feint.Core.Graphics.RenderSize.y / 2, Feint.Core.Graphics.RenderSize.y / 2 - 300)
			Transform.trueSizeX = Transform.scaleX / Transform.sizeX
			Transform.trueSizeY = Transform.scaleY / Transform.sizeY

			local trueSizeX = Transform.trueSizeX
			local trueSizeY = Transform.trueSizeY
			rect(Transform.x - trueSizeX / 2, Transform.y - trueSizeY / 2, Transform.angle, trueSizeX, trueSizeY)
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

			rect(x - trueSizeX / 2, y - trueSizeY / 2, angle, trueSizeX, trueSizeY)
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
	-- 	local angle = Feint.Core.Util:getTime()
	-- 	local rect = Feint.Core.Graphics.rectangleInt
	-- 	rect(lx, ly, angle, px, py, angle, 1, 1)
	-- 	local rect = Feint.Core.Graphics.rectangle
	-- 	rect(px, py, angle, 1, 1)
	-- end

	local sin, cos, pi = math.sin, math.cos, math.pi
	-- local rect = Feint.Core.Graphics.rectangle
	local time = Feint.Core.Util:getTime()
	for i = 1, 1, 1 do
		if Feint.ECS.FFI_OPTIMIZATIONS then
			self.EntityManager:forEach("sdads", function(Data, Entity, Renderer, Transform)
				Transform.angle = Transform.angle + 1 / 60 * pi -- + Entity * 6
				Transform.x = Transform.x + sin(time * 2 + Entity * 0.25) * 0.5
				Transform.y = Transform.y + cos(time * 2 + Entity * 0.25) * 0.5

				-- local trueSizeX = Transform.trueSizeX
				-- local trueSizeY = Transform.trueSizeY

				-- rect(Transform.x - trueSizeX / 2, Transform.y - trueSizeY / 2, Transform.angle, trueSizeX, trueSizeY)
			end)
		else
			self.EntityManager:forEach("sdads", function(Data, Entity, Renderer, Transform)
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
