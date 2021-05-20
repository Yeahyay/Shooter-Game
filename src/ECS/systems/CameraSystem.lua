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

function CameraSystem:update(EntityManager)
	EntityManager:forEachNotParallel("CameraSystem_update", function()
		local execute = function(Entity, Transform, Physics, Camera)
			-- print(Camera.target)
			-- Graphics.Camera:setPosition(Transform)
		end
		return execute
	end)
end

return CameraSystem
