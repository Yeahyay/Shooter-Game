local ECSUtils = Feint.ECS.Util

local EntityManager = ECSUtils.newClass("EntityManager")
local EntityArchetype = Feint.ECS.EntityArchetype
local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
function EntityManager:init(name)
	self.name = name
	self.entities = {} -- {[index] = idIndex}
	self.entitiesCount = 0
	self.entityID = {} -- {[idIndex] = id}
	self.entityIDState = {} -- {[idIndex] = state}

	self.archetypes = {}
	self.archetypesCount = 0
	self.archetypeChunks = {}
	self.archetypesChunksCount = 0

	self.forEachJobs = {}

	-- self.ID_INDEX = 0
	self.EntityQueryBuilder = EntityQueryBuilder:new("EntityManager_EntityQueryBuilder")
end

function EntityManager:getNewEntityId()
	-- local reuseID = false
	local newID = -1
	-- local newIDIndex = -1
	for i = 1, self.entitiesCount do--#self.entities do
		if self.entityIDState[i] == true then
			-- reuseID = true
			newID = self.entityID[i]
			-- newIDIndex = i
			break
		end
	end

	-- self.entities
	return newID
end

function EntityManager:CreateEntity(archetype)
end
-- EntityManager.CreateEntity = Feint.Util.Memoize(EntityManager.CreateEntity)

function EntityManager:newArchetype(components)
	local archetype = EntityArchetype:new("?", components)
	self.archetypes[archetype.Name] = archetype
	return archetype
end

-- local function getEntity()
-- 	local entity = nil
-- 	return entity
-- end

local getEntities = --Feint.Util.Memoize(function(query)
(function(query)
	-- printf("Getting Entities from Query\n")
	local entities = {}
	return entities
end)

function EntityManager:buildQuery(arguments, componentsCount)
	-- print(components, componentsCount)
	-- printf("Building EntityQuery for components: ")

	-- local components = {}--{false, false, false, false, false, false}--Feint.Util.Table.preallocate(componentsCount)

	-- for i = 1, componentsCount, 1 do
	-- 	local componentData = arguments[i]
	-- 	-- local name = componentData.Name
	-- 	if not componentData.componentData then
	-- 		goto forEnd
	-- 	end
	--
	-- 	-- assert(arguments[i] ~= nil, string.format("Component %d does not exist\n", i))
	-- 	-- if i < componentsCount then
	-- 	-- 	printf("%s, ", arguments[i].Name or "nonexistent")
	-- 	-- end
	-- 	components[#components + 1] = componentData
	-- 	::forEnd::
	-- end

	-- assert(arguments[#arguments] ~= nil, string.format("Component %d does not exist\n", #arguments))
	-- if #arguments > 0 then
	-- 	printf("%s\n", arguments[#arguments].Name or "nonexistent")
	-- end

	local queryBuilder = self.EntityQueryBuilder
	local query = queryBuilder:withAll(arguments):build();
	return query
end

function EntityManager:execute(entities, callback)
	-- printf("Calling function on entities\n")
end

local getTime = love.timer.getTime
local avg = 0
local avgTimes = 0

local input = Feint.Input
local px, py = 0, 0
local lx, ly = 0, 0
function EntityManager:forEach(system, arguments, callback)
	-- MAKE THIS THREADED
	-- printf("\nforEach from System \"%s\"\n", system.Name)

	do
		lx, ly = px, py
		px, py = input.mouse.PositionRaw.x - 50 / 2, input.mouse.PositionRaw.y + 50 / 2
		Feint.Graphics.rectangle(lx, ly, 0, "fill", px, py, 50, 50)
	end

	local startTime = getTime()

	-- generate an entity query that fits the specified arguments
	local query = nil
	for i = 1, 42500, 1 do
		query = self:buildQuery(self, arguments, #arguments)
	end

	local endTime = getTime() - startTime
	-- printf("TIME: %10.6fms, %10.6f%% of frame time\n", endTime * 1000, endTime / (1 / Feint.Run.framerate) * 100)
	avg = avg + endTime
	avgTimes = avgTimes + 1
	-- printf("AVG:  %10.6fms, %10.6f%% of frame time\n", avg / avgTimes * 1000, endTime / (1 / Feint.Run.framerate) * 100)

	-- collectgarbage()
	-- collectgarbage()

	self:execute(getEntities(query), callback)
	-- printf("Finished forEach\n\n")
end

function EntityManager:removeEntity(id)
	self.entityIds[id] = nil
end

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
