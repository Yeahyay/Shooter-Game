local ECS = {
	depends = {
		"Core.Paths", "ECS.Util", "Core.Time",
		"Core.Graphics", "Util.Table", "Log"
	}
}

function ECS:load()
	local Paths = Feint.Core.Paths
	Paths:Add("ECS", Paths.Modules .. "ECS") -- add path
	Paths:Add("ECS_Entity", Paths.ECS .. "Entity") -- add path

	self.ENTITIY_MANAGER_ID_MODE = ""

	self.Archetype = require(Paths.ECS_Entity .. "Archetype")
	-- self.EntityArchetypeChunk = require(Paths.ECS_Entity .. "ArchetypeChunk")
	-- self.EntityArchetypeChunkManager = require(Paths.ECS_Entity .. "ArchetypeChunkManager")

	-- self.EntityQuery = require(Paths.ECS_Entity .. "EntityQuery")
	-- self.EntityQueryBuilder = require(Paths.ECS_Entity .. "EntityQueryBuilder")

	self.Component = require(Paths.ECS .. "Component")
	-- self.EntityManager = require(Paths.ECS_Entity .. "EntityManager")

	self.World = require(Paths.ECS .. "World")
	self.World.DefaultWorld = self.World:new("DefaultWorld")
	-- self.System = require(Paths.ECS .. "System")

	Paths:Add("Game_ECS_Files", "src.ECS")
	Paths:Add("Game_ECS_Bootstrap", Paths.Game_ECS_Files.."bootstrap", "file")
	Paths:Add("Game_ECS_Components", Paths.Game_ECS_Files.."components")
	Paths:Add("Game_ECS_Systems", Paths.Game_ECS_Files.."systems")
	function self:init()

		self.World.DefaultWorld:addComponentsFromDirectory(Paths:SlashDelimited(Paths.Game_ECS_Components))
		self.World.DefaultWorld:addSystemsFromDirectory(Paths:SlashDelimited(Paths.Game_ECS_Systems))

		printf("\n%s update order:\n", self.World.DefaultWorld.Name)
		self.World.DefaultWorld:generateUpdateOrderList()
		print(#self.World.DefaultWorld.updateOrder)
		for k, v in ipairs(self.World.DefaultWorld.updateOrder) do
			printf("%d: %s\n", k, self.World.DefaultWorld.systems[k].Name)
		end
		print()

		-- self.World.DefaultWorld:start()
	end

	function self:setComponentString(component, string, value)
		-- component[string] =
	end
end

return ECS
