local ECSUtils = Feint.ECS.Util

local EntityManager = ECSUtils.newClass("EntityManager")
local EntityArchetype = Feint.ECS.EntityArchetype
local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk
local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
function EntityManager:init(world --[[name]])
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

	self.World = world
end

function EntityManager:getNewEntityId()
	-- local reuseID = false
	local newID = -1 -- luacheck:ignore
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
	local currentArchetypeChunkTable = self:getArchetypeChunkTable(archetype)
	local currentArchetypeChunkTableCount = self.archetypeChunksCount[archetype]

	local currentArchetypeChunk = currentArchetypeChunkTable[currentArchetypeChunkTableCount]
	if currentArchetypeChunk:isFull() then
		-- Feint.Log.logln(currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes)
		-- Feint.Log.logln((currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes) / 1024)
		currentArchetypeChunk = self:newArchetypeChunk(archetype)
	end
	return currentArchetypeChunk
end

function EntityManager:CreateEntity(archetype)
	-- print(archetype)
	Feint.Log.logln("Creating entity from archetype ".. archetype.archetypeString)
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
	return archetype
end

function EntityManager:getArchetypeChunkTable(archetype)
	local currentArchetypeChunkTable = self.archetypeChunks[archetype]
	if not currentArchetypeChunkTable then
		self.archetypeChunks[archetype] = {}
		self.archetypeChunksCount[archetype] = 0
		currentArchetypeChunkTable = self.archetypeChunks[archetype]
	end
	return currentArchetypeChunkTable
end

function EntityManager:newArchetypeChunk(archetype)
	local archetypeChunk = EntityArchetypeChunk:new(archetype)

	local currentArchetypeChunkTable = self:getArchetypeChunkTable(archetype)

	self.archetypeChunksCount[archetype] = self.archetypeChunksCount[archetype] + 1
	currentArchetypeChunkTable[self.archetypeChunksCount[archetype]] = archetypeChunk

	Feint.Log.logln("Creating archetype chunk " .. archetypeChunk.Name)
	return archetypeChunk
end

local getEntities = --Feint.Util.Memoize(function(query)
(function(query)
	-- printf("Getting Entities from Query\n")
	local entities = {}
	return entities
end)

function EntityManager:buildQuery(arguments, componentsCount)
	local queryBuilder = self.EntityQueryBuilder
	local query = queryBuilder:withAll(arguments):build();
	return query
end

function EntityManager:execute(arguments, archetype, callback)
	-- printf("Calling function on entities\n")
	local archetypeChunks = self.archetypeChunks
	local a1, a2, a3, a4, a5, a6 = unpack(arguments)--arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]

	for i = 1, self.archetypeChunksCount[archetype], 1 do
		local archetypeChunk = self.archetypeChunks[archetype][i]
		local idList = archetypeChunk.entityIndexToId
		local data = archetypeChunk.data

		for j = 1, archetypeChunk.numEntities, 1 do
			local offset = (j - 1) * archetypeChunk.entitySize + 1
			callback(data, idList[j], offset, a3[1] + offset)
		end									 -- [1] is actually .size
	end
end

function EntityManager:getArchetype(arguments)
	local stringTable = {}
	for i = 1, #arguments do
		local v = arguments[i]
		if v.componentData then
			stringTable[#stringTable + 1] = v.Name
		end
	end
	return table.concat(stringTable)
end
Feint.Util.Memoize(EntityManager.getArchetype)

local getArchetypeUn = Feint.Util.Memoize(function(...)
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

local componentCache = {}
local argumentCache = {}
function EntityManager:forEach(id, callback)
	if not componentCache[id] then
		componentCache[id] = {}
		argumentCache[id] = {}

		local funcInfo = debug.getinfo(callback)
		local i = 1
		for j = 1, funcInfo.nparams, 1 do
			-- print(debug.getlocal(callback, i))
			local componentName = debug.getlocal(callback, j)
			-- argumentCache[id][j] = argumentName
			if componentName ~= "Data" and componentName ~= "Entity" then
				local component = self.World.components[componentName]
				if component.componentData then
					assert(component, 2, string.format("arg %d (%s) is not a component", i, componentName))
					componentCache[id][i] = component
					i = i + 1
				end
			else
				componentCache[id][i] = componentName
				i = i + 1
			end
		end
	end

	local archetypeString = self:getArchetype(componentCache[id])
	self:execute(componentCache[id], self.archetypes[archetypeString], callback)

end
-- Feint.Util.Memoize(EntityManager.forEach)

function EntityManager:removeEntity(id)
	self.entityIds[id] = nil
end

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
