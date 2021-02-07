local ECS = {
	depends = {
		"Core.Paths", "ECS.Util", "Core.Time",
		"Core.Graphics", "Util.Table", "Log"
	}
}

function ECS:load()
	local Paths = Feint.Core.Paths
	Paths:Add("ECS", Paths.Modules .. "ECS") -- add path

	self.FFI_OPTIMIZATIONS = true

	self.EntityArchetype = require(Paths.ECS .. "EntityArchetype")
	self.EntityArchetypeChunk = require(Paths.ECS .. "EntityArchetypeChunk")

	self.EntityQuery = require(Paths.ECS .. "EntityQuery")
	self.EntityQueryBuilder = require(Paths.ECS .. "EntityQueryBuilder")

	-- self.EntityManagerArchetypeMethods = require(Paths.ECS .. "EntityManagerArchetypeMethods")
	-- self.EntityManagerExecuteFunctions = require(Paths.ECS .. "EntityManagerExecuteFunctions")
	self.EntityManager = require(Paths.ECS .. "EntityManager")

	self.World = require(Paths.ECS .. "World")
	self.Component = require(Paths.ECS .. "Component")
	self.System = require(Paths.ECS .. "System")

	function self:init()
		Paths:Add("Game_ECS_Files", "src.ECS")
		Paths:Add("Game_ECS_Bootstrap", Paths.Game_ECS_Files.."bootstrap", "file")
		Paths:Add("Game_ECS_Components", Paths.Game_ECS_Files.."components")
		Paths:Add("Game_ECS_Systems", Paths.Game_ECS_Files.."systems")
		local systems = {} -- luacheck: ignore
		local systemCount = 0
		for k, v in pairs(love.filesystem.getDirectoryItems(Paths:SlashDelimited(Paths.Game_ECS_Systems))) do
			if v:match(".lua") then
				local path = Paths.Game_ECS_Systems..v:gsub(".lua", "")
				local system = require(path)
				systemCount = systemCount + 1
				systems[systemCount] = system
				self.World.DefaultWorld:registerSystem(system)
			end
		end

		local Log = Feint.Log
		Log.log("\n%s update order:\n", self.World.DefaultWorld.Name)
		self.World.DefaultWorld:generateUpdateOrderList()
		for k, v in ipairs(self.World.DefaultWorld.updateOrder) do
			printf("%d: %s\n", k, self.World.DefaultWorld.systems[k].Name)
		end
		print()

		self.World.DefaultWorld:start()
	end

	function self:setComponentString(component, string, value)
		-- component[string] =
	end
end

return ECS
