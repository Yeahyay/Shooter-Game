local System = Feint.ECS.System
local World = Feint.ECS.World

local PlayerSystem = System:new("PlayerSystem")

function PlayerSystem:init()

end
function PlayerSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	local Camera = world:getComponent("Camera")
	local archetype = EntityManager:newArchetypeFromComponents{Transform, Physics, Camera}
	for i = 1, 1, 1 do
		EntityManager:createEntityFromArchetype(archetype)
	end
end
function PlayerSystem:update(EntityManager)
	EntityManager:forEachNotParallel("PlayerSystem_update", function()
		local execute = function(Entity, Transform, Physics, Camera)
			-- print(Camera.target)
		end
		return execute
	end)
end

return PlayerSystem
