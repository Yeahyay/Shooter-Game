local System = Feint.ECS.System
local World = Feint.ECS.World

local PlayerSystem = System:new("PlayerSystem")

function PlayerSystem:init()

end
function PlayerSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	local Player = world:getComponent("Player")
	local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform, Player}
	EntityManager:createEntityFromArchetype(archetype)

	EntityManager:forEachNotParallel("PlayerSystem_start", function()
		local execute = function(Entity, Player, Renderer)
			print(Entity, Player)
		end
		return execute
	end)
end
function PlayerSystem:update(EntityManager)
	-- EntityManager:forEachNotParallel("PlayerSystem_update", function()
	-- 	local execute = function(Entity, Player)
	-- 		-- print(Entity, Transform, "PLAYER")
	-- 	end
	-- 	return execute
	-- end)
end

return PlayerSystem
