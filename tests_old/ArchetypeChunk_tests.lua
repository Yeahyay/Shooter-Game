local cute = require("Cute-0_4_0.cute")

local World = Feint.ECS.World

local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk

-- cute.notion("Archetype Chunk instantiation is proper", function()
-- 	local world = World.DefaultWorld
-- 	local EntityManager = world.EntityManager
-- 	local Renderer = world:getComponent("Renderer")
-- 	local Transform = world:getComponent("Transform")
-- 	local Physics = world:getComponent("Physics")
-- 	local Player = world:getComponent("Player")
-- 	local Health = world:getComponent("Health")
-- 	local CameraFocus = world:getComponent("CameraFocus")
-- 	local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform, Physics, Player, Health, CameraFocus}
-- 	for i = 1, 1000, 1 do
-- 		local archetypeChunk = EntityArchetypeChunk:new(archetype)
-- 	end
-- 	return true
-- end)
