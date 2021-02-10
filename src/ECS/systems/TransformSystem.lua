-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math
local random2 = fmath.random2

local TransformSystem = System:new("TransformSystem")
function TransformSystem:init(...)
end

function TransformSystem:start(EntityManager)
	-- local world = World.DefaultWorld
	-- local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
	-- local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform}

	-- EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
	-- 	Transform.x = random2(Feint.Core.Graphics.RenderSize.x / 2)
	-- 	Transform.y = random2(-Feint.Core.Graphics.RenderSize.y / 2, Feint.Core.Graphics.RenderSize.y / 2 - 300)
	-- end)
end

function TransformSystem:update(EntityManager, dt)
	-- local sin, cos, pi = math.sin, math.cos, math.pi
	-- -- local graphics = Feint.Core.Graphics
	-- local time = Feint.Core.Time:getTime()
	-- local oscillate = Feint.Math.oscillateManualSigned
	--
	-- EntityManager:forEach("main", function(Data, Entity, Renderer, Transform)
	-- 	Transform.angle = (time + Entity / 10) * pi -- + Entity * 6
	-- 	Transform.x = oscillate(time, 50, 2, Entity)
	-- 	Transform.y = oscillate(time, 50, 2, (Entity * Entity) % (2 * math.pi))
	-- end)
end

return TransformSystem
