local System = Feint.ECS.System
local World = Feint.ECS.World
local Graphics = Feint.Core.Graphics

local CameraSystem = System:new("CameraSystem")
function CameraSystem:init()
end
function CameraSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	local Camera = world:getComponent("Camera")
	local archetype = EntityManager:newArchetypeFromComponents{Transform, Physics, Camera}
	for i = 1, 1, 1 do
		EntityManager:createEntityFromArchetype(archetype)
	end
end

local focus
function CameraSystem:update(EntityManager)
	Feint.Core.Graphics.Camera:setPosition(Feint.Core.Input.Mouse.Position:split())
	EntityManager:forEachNotParallel("CameraSystem_getEntity", function()
		local execute = function(Entity, CameraFocus)
			focus = Entity
		end
		return execute
	end)
	-- EntityManager:forEachNotParallel("CameraSystem_update", function()
	-- 	local execute = function(Entity, Transform, Physics, Camera)
	-- 		Camera.target = focus
	-- 		local data = EntityManager:getEntityDataFromID(Camera.target)
	-- 		if data then
	-- 			Graphics.Camera:setPosition(data.Transform.x, data.Transform.y)
	-- 		end
	-- 	end
	-- 	return execute
	-- end)
end

return CameraSystem
