local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

function RenderSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	for i = 1, 100, 1 do
		EntityManager:createEntityFromComponents{Renderer, Transform}
	end

	-- local r = {}
	-- for k, v in pairs(Feint.Core.Graphics:getTextures()) do
	-- 	r[#r + 1] = k
	-- 	-- print(#r, r[#r])
	-- end

	EntityManager:forEachNotParallel("rendersystem_start", function()
		local graphics = Feint.Core.Graphics

		local function execute(Entity, Renderer, Transform)
			Transform.trueSizeX = Transform.scaleX / Transform.sizeX
			Transform.trueSizeY = Transform.scaleY / Transform.sizeY
			local trueSizeX = Transform.trueSizeX
			local trueSizeY = Transform.trueSizeY

			Renderer.texture = Feint.Core.FFI.cstring("walking1.png")
			Renderer.id = graphics:addRectangle(
				Renderer.texture,-- Renderer.textureLength,
				Transform.x - trueSizeX / 2, Transform.y - trueSizeY / 2, Transform.angle, trueSizeX, trueSizeY,
				Transform.sizeX / 2, Transform.sizeY / 2
			)
			-- Renderer.id = math.floor(Feint.Math.random2(1, 100))
			-- print(Renderer.id)
		end
		return execute
	end)
end

-- local input = Feint.Core.Input
-- local px, py = 0, 0
-- local lx, ly = 0, 0
function RenderSystem:update(EntityManager, dt)
	-- do
	-- 	lx, ly = px, py
	-- 	px, py = input.mouse.Position.x, input.mouse.Position.y
	-- 	local angle = Feint.Core.Time:getTime()
	-- 	local rect = Feint.Core.Graphics.rectangleInt
	-- 	rect(lx, ly, angle, px, py, angle, 1, 1)
	-- 	local rect = Feint.Core.Graphics.rectangle
	-- 	rect(px, py, angle, 1, 1)
	-- end

	EntityManager:forEachNotParallel("RenderSystem_update", function()
		-- local sin = math.sin
		-- local cos = math.cos
		-- local pi = math.pi
		local graphics = Feint.Core.Graphics
		-- local time = Feint.Core.Time:getTime()
		-- local oscillate = Feint.Math.oscillateManualSigned
		-- print("noiokoij")

		local function execute(Entity, Renderer, Transform)
			-- print(Entity, "innkkopk")
			-- print(Entity, Renderer, "RENDERER")
			print(Transform.x, Transform.y, Transform)
			graphics:modify(
				Renderer.texture,
				Renderer.id,
				Transform.x,
				Transform.y,
				Transform.angle,
				Transform.trueSizeX,
				Transform.trueSizeY
			)
		end
		return execute
	end)
end

return RenderSystem
