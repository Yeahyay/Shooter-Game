local cute = require("Cute-0_4_0.cute")

local World = Feint.ECS.World

local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk

cute.notion("EntityManager instantiation is proper", function()
	local world = World.DefaultWorld

	local EntityManager = world.EntityManager

	cute.check(EntityManager ~= nil).is(true)


	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	local Player = world:getComponent("Player")
	local Health = world:getComponent("Health")
	local CameraFocus = world:getComponent("CameraFocus")
	local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform, Physics, Player, Health, CameraFocus}

	for runs = 1, 1000, 1 do
		printf("entity manager run %d\n", runs)
		printf("entity manager mem pre    : %d\n", Feint.Core.Util:getMemoryUsageBytes())
		local archetypeChunk = EntityArchetypeChunk:new(archetype)
		printf("entity manager mem post   : %d\n", Feint.Core.Util:getMemoryUsageBytes())
		collectgarbage()
		collectgarbage()
		printf("entity manager mem collect: %d\n", Feint.Core.Util:getMemoryUsageBytes())
	end
	return true
end)
