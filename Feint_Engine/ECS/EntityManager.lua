local ECSUtils = Feint.ECS.Util

local EntityManager = ECSUtils.newClass("EntityManager")
local EntityArchetype = Feint.ECS.EntityArchetype
local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk
local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
function EntityManager:init(--[[name]])
	-- self.name = name
	self.entities = {} -- {[index] = idIndex}
	self.entitiesCount = 0
	self.entityID = {} -- {[idIndex] = id}
	self.entityIDState = {} -- {[idIndex] = state}

	self.archetypes = {} -- all entity archetypes
	self.archetypeCount = 0
	self.archetypeChunks = {} -- a hash table of a list of archetype chunks
	self.archetypeChunksCount = {}
	self.archetypeChunksOpenStacks = setmetatable({}, {__mode = "k, v"}) -- queue of open archetype chunks

	self.forEachJobs = {}

	-- self.ID_INDEX = 0
	self.EntityQueryBuilder = EntityQueryBuilder:new()--"EntityManager_EntityQueryBuilder")
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

	self.entitiesCount = self.entitiesCount + 1
	-- self.entities
	return self.entitiesCount --newID
end

function EntityManager:getNextArchetypeChunk(archetype)
	local currentArchetypeChunkTable = self.archetypeChunks[archetype]
	local currentArchetypeChunkTableCount = self.archetypeChunksCount[archetype]

	local currentArchetypeChunk = currentArchetypeChunkTable[currentArchetypeChunkTableCount]
	if currentArchetypeChunk:isFull() then
		Feint.Log.logln(currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes)
			Feint.Log.logln((currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes) / 1024)
		self:newArchetypeChunk(archetype)
		-- error()
	end
	return currentArchetypeChunk
end

function EntityManager:CreateEntity(archetype)
	-- Feint.Log.logln("Creating entity from archetype ".. archetype.archetypeString)
	local archetypeChunk = self:getNextArchetypeChunk(archetype)
	return archetypeChunk:newEntity(self:getNewEntityId())
end
-- EntityManager.CreateEntity = Feint.Util.Memoize(EntityManager.CreateEntity)

function EntityManager:newArchetype(components)
	local archetype = EntityArchetype:new(components)
	self.archetypes[archetype.archetypeString] = archetype
	self.archetypeCount = self.archetypeCount + 1
	Feint.Log.logln("Creating archetype " .. archetype.Name)

	self:newArchetypeChunk(archetype)

	-- for k, v in pairs(self.archetypeChunks) do
		-- print(k.archetypeString, v[1].archetype.archetypeString)
		-- for k, v in pairs(v) do print("asd", k, v) end
		-- print(self.archetypeChunksCount[v.archetype])
	-- end
	return archetype
end

function EntityManager:newArchetypeChunk(archetype)
	local archetypeChunk = EntityArchetypeChunk:new(archetype)

	local currentArchetypeChunkTable = self.archetypeChunks[archetype]
	if not currentArchetypeChunkTable then
		self.archetypeChunks[archetype] = {}
		self.archetypeChunksCount[archetype] = 0
		currentArchetypeChunkTable = self.archetypeChunks[archetype]
	end

	self.archetypeChunksCount[archetype] = self.archetypeChunksCount[archetype] + 1
	currentArchetypeChunkTable[self.archetypeChunksCount[archetype]] = archetypeChunk

	Feint.Log.logln("Creating archetype chunk " .. archetypeChunk.Name)
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
	-- printf("Building EntityQuery for components: ")

	-- local components = {nil, nil, nil, nil, nil, nil}--Feint.Util.Table.preallocate(componentsCount)
	--
	-- for i = 1, componentsCount, 1 do
	-- 	local componentData = arguments[i]
	-- 	-- local name = componentData.Name
	-- 	-- if not componentData.componentData then
	-- 	-- 	goto forEnd
	-- 	-- end
	--
	-- 	-- assert(arguments[i] ~= nil, string.format("Component %d does not exist\n", i))
	-- 	-- if i < componentsCount then
	-- 	-- 	printf("%s, ", arguments[i].Name or "nonexistent")
	-- 	-- end
	-- 	components[#components + 1] = componentData
	-- 	-- ::forEnd::
	-- end

	-- assert(arguments[#arguments] ~= nil, string.format("Component %d does not exist\n", #arguments))
	-- if #arguments > 0 then
	-- 	printf("%s\n", arguments[#arguments].Name or "nonexistent")
	-- end

	local queryBuilder = self.EntityQueryBuilder
	local query = queryBuilder:withAll(arguments):build();
	return query
end

function EntityManager:execute(arguments, archetype, callback)
	-- printf("Calling function on entities\n")
	local archetypeChunks = self.archetypeChunks[archetype]
	local a1, a2, a3, a4, a5, a6 = unpack(arguments)--arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]
	for i = 1, self.archetypeChunksCount[archetype], 1 do
		local archetypeChunk = archetypeChunks[i]
		local idList = archetypeChunk.entityIndexToId
		local data = archetypeChunk.data

		for i = 1, archetypeChunk.numEntities, 1 do
			local offset = (i - 1) * archetypeChunk.entitySize
			-- print(offset)
			callback(data, idList[i], a2[1] + offset, a3[1] + offset)
		end									 -- [1] is actually .size
	end
end

local getArchetype = Feint.Util.Memoize(function(...)
	local arguments = {...}
	local stringTable = {}
	for i = 1, #arguments do
		local v = arguments[i]
		if v.componentData then
			stringTable[#stringTable + 1] = v.Name
		end
	end
	return table.concat(stringTable)
end)

function EntityManager:forEach(system, arguments, callback)
	-- MAKE THIS THREADED
	-- printf("\nforEach from System \"%s\"\n", system.Name)


	-- generate an entity query that fits the specified arguments

	-- local query = self:buildQuery(arguments, #arguments)

	-- collectgarbage()
	-- collectgarbage()

	-- for k, v in pairs(arguments) do print(k, v) end

	local archetypeString = getArchetype(unpack(arguments))
	self:execute(arguments, self.archetypes[archetypeString], callback)
	-- self:execute(query:getArchetypeChunks(self.archetypeChunks), callback)
	-- printf("Finished forEach\n\n")
end

function EntityManager:removeEntity(id)
	self.entityIds[id] = nil
end

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
