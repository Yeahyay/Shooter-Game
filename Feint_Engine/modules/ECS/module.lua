local ECS = {
	depends = {"Core.Paths", "ECS.Util", "Core.Run", "Core.Graphics", "Util.Table"}
}

local paths
function ECS:load()
	paths = Feint.Core.Paths

	self.FFI_OPTIMIZATIONS = true

	paths.Add("ECS", paths.Modules .. "ECS") -- add path

	-- for k, v in pairs(Feint.Core) do
	-- 	print(k, v)
	-- end

	-- print(Feint.ECS.Util)
	-- for k, v in pairs(Feint.ECS.Util) do
	-- 	print(k, v)
	-- end


	print(Feint.Util)
	print(Feint.Util.Table)

	self.EntityArchetype = require(paths.ECS .. "EntityArchetype")
	self.EntityArchetypeChunk = require(paths.ECS .. "EntityArchetypeChunk")

	self.EntityQuery = require(paths.ECS .. "EntityQuery")
	self.EntityQueryBuilder = require(paths.ECS .. "EntityQueryBuilder")

	self.EntityManager = require(paths.ECS .. "EntityManager")
	self.World = require(paths.ECS .. "World")
	self.Component = require(paths.ECS .. "Component")
	self.System = require(paths.ECS .. "System")

	-- print(self.System)

	-- for k, v in pairs(Feint.Paths) do
	-- 	print(k, v)
	-- end
end

return ECS
