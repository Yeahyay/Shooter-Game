-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math
local random2 = fmath.random2

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

function RenderSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
	local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform}
	for i = 1, 1000, 1 do
		EntityManager:createEntityFromArchetype(archetype)
	end

	local r = {}
	for k, v in pairs(Feint.Core.Graphics:getTextures()) do
		r[#r + 1] = k
		-- print(#r, r[#r])
	end

	-- local graphics = Feint.Core.Graphics
	if Feint.ECS.FFI_OPTIMIZATIONS then
		EntityManager:forEachNotParallel2("rendersystem_start", function()
			local graphics = Feint.Core.Graphics

			local function execute(Data, Entity, Renderer, Transform)
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
	else
		-- luacheck: push ignore
		EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
			-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
			-- local x = Data[Transform]
			-- local y = Data[Transform + 1]
			-- local x = random2(Feint.Core.Graphics.RenderSize.x / 2)
			-- local y = random2(-Feint.Core.Graphics.RenderSize.y / 2, Feint.Core.Graphics.RenderSize.y / 2 - 300)
			local angle = Data[Transform + 2]
			local sizeX = Data[Transform + 3]
			local sizeY = Data[Transform + 4]
			local scaleX = Data[Transform + 5]
			local scaleY = Data[Transform + 6]
			local trueSizeX = scaleX / sizeX
			local trueSizeY = scaleY / sizeY

			-- Data[Transform] = x
			-- Data[Transform + 1] = y
			Data[Transform + 7] = trueSizeX
			Data[Transform + 8] = trueSizeY

			-- Renderer.id = graphics:addRectangle(
			-- 	x - trueSizeX / 2, y - trueSizeY / 2, angle, trueSizeX, trueSizeY
			-- )
		end)
		-- luacheck: pop ignore
	end
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

	local sin, cos, pi = math.sin, math.cos, math.pi
	-- local graphics = Feint.Core.Graphics
	local time = Feint.Core.Time:getTime()
	-- local oscillate = Feint.Math.oscillateManualSigned
	-- print("time", time)
	if Feint.ECS.FFI_OPTIMIZATIONS then
		EntityManager:forEachNotParallel2("rendersystem_main", function()
			-- local sin = math.sin
			-- local cos = math.cos
			-- local pi = math.pi
			local graphics = Feint.Core.Graphics
			-- local time = Feint.Core.Time:getTime()
			-- local oscillate = Feint.Math.oscillateManualSigned

			local function execute(Data, Entity, Renderer, Transform)
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
	else
		EntityManager:forEach("main", function(Data, Entity, Renderer, Transform)
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

return RenderSystem
