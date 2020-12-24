local ECS = {
	depends = {"Core.Paths", "ECS.Util", "Core.Run", "Core.Graphics", "Util.Table"}
}

local paths
function ECS:load()
	paths = Feint.Core.Paths
	paths.Add("ECS", paths.Modules .. "ECS") -- add path

	self.FFI_OPTIMIZATIONS = true

	self.EntityArchetype = require(paths.ECS .. "EntityArchetype")
	self.EntityArchetypeChunk = require(paths.ECS .. "EntityArchetypeChunk")

	self.EntityQuery = require(paths.ECS .. "EntityQuery")
	self.EntityQueryBuilder = require(paths.ECS .. "EntityQueryBuilder")

	self.EntityManager = require(paths.ECS .. "EntityManager")
	self.World = require(paths.ECS .. "World")
	self.Component = require(paths.ECS .. "Component")
	self.System = require(paths.ECS .. "System")
end

return ECS
