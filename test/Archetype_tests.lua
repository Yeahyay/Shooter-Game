local cute = require("Cute-0_4_0.cute")

local World = Feint.ECS.World

local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk

cute.notion("Archetype instantiation is proper", function()
	local world = World.DefaultWorld
	local EntityManager = world.EntityManager

	local Renderer = world:getComponent("Renderer")
	cute.check(Renderer.componentData).is(true)

	local Transform = world:getComponent("Transform")
	cute.check(Transform.componentData).is(true)

	local Physics = world:getComponent("Physics")
	cute.check(Physics.componentData).is(true)

	local Player = world:getComponent("Player")
	cute.check(Player.componentData).is(true)

	local Health = world:getComponent("Health")
	cute.check(Health.componentData).is(true)

	local CameraFocus = world:getComponent("CameraFocus")
	cute.check(CameraFocus.componentData).is(true)

	-- local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform, Physics, Player, Health, CameraFocus}

	-- for i = 1, 1000, 1 do
	-- 	local archetypeChunk = EntityArchetypeChunk:new(archetype)
	-- end
	-- return true
end)
