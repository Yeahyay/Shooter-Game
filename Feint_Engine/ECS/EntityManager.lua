-- local ffi = require("ffi")

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
			-- reuseID = true9
			newID = self.entityID[i]
			-- newIDIndex = i
			break
		end
	end

	self.entitiesCount = self.entitiesCount + 1
	-- self.entities
	return self.entitiesCount --newID
end

function EntityManager:newArchetype(components)
	local archetype = EntityArchetype:new(components)
	self.archetypes[archetype.archetypeString] = archetype
	self.archetypeCount = self.archetypeCount + 1
	Feint.Log.logln("Creating archetype " .. archetype.Name)

	self:newArchetypeChunk(archetype)
	return archetype
end

function EntityManager:getArchetypeString(arguments)
	local stringTable = {}
	assert(arguments, 3, "no arguments")
	for i = 1, #arguments do
		local v = arguments[i]
		if v.componentData then
			stringTable[#stringTable + 1] = v.Name
		end
	end
	return table.concat(stringTable)
end
-- Feint.Util.Memoize(EntityManager.getArchetypeString)

function EntityManager:getArchetype(arguments)
	-- print(arguments[1])
	local archetypeString = self:getArchetypeString(arguments)
	-- print(archetypeString)
	return self.archetypes[archetypeString]
end

function EntityManager:newArchetypeChunk(archetype)
	local archetypeChunk = EntityArchetypeChunk:new(archetype)

	local currentArchetypeChunkTable = self:getArchetypeChunkTable(archetype)

	self.archetypeChunksCount[archetype] = self.archetypeChunksCount[archetype] + 1
	currentArchetypeChunkTable[self.archetypeChunksCount[archetype]] = archetypeChunk

	-- Feint.Log.logln("Creating archetype chunk " .. archetypeChunk.Name)
	return archetypeChunk
end

function EntityManager:getNextArchetypeChunk(archetype)
	local currentArchetypeChunkTable = self:getArchetypeChunkTable(archetype)
	-- print(archetype)
	assert(self.archetypes[archetype.archetypeString], 2,
		string.format("Archetype %s does not exist", archetype.archetypeString))
	local currentArchetypeChunkTableCount = self.archetypeChunksCount[archetype]

	local currentArchetypeChunk = currentArchetypeChunkTable[currentArchetypeChunkTableCount]

	if currentArchetypeChunk:isFull() then
		-- Feint.Log.logln(currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes)
		-- Feint.Log.logln((currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes) / 1024)
		currentArchetypeChunk = self:newArchetypeChunk(archetype)
	end
	return currentArchetypeChunk
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

function EntityManager:CreateEntity(archetype)
	-- print(archetype)
	-- Feint.Log.logln("Creating entity from archetype ".. archetype.archetypeString)
	local archetypeChunk = self:getNextArchetypeChunk(archetype)
	local id = self:getNewEntityId()
	-- assosciate the entity id with its respective chunk
	self.entities[id] = {archetypeChunk, archetypeChunk.entityIdToIndex[id]}
	archetypeChunk:newEntity(id)
	return id
end

function EntityManager:getArchetypeChunkFromEntity(id)
	return self.entities[id][1]
end

function EntityManager:getArchetypeChunkEntityIndexFromEntity(id)
	return self.entities[id][2]
end

function EntityManager:getEntities(query)
	-- printf("Getting Entities from Query\n")
	local entities = {}
	return entities
end
-- Feint.Util.Memoize(EntityManager.getEntities)

function EntityManager:setComponentData(entity, component, data)
	local archetypeChunk = self:getArchetypeChunkFromEntity(entity)
	local index = self:getArchetypeChunkEntityIndexFromEntity(entity)
	local archetypeChunkData = archetypeChunk.data
	-- local offset =
	for i = 1, #data, 1 do
		archetypeChunkData[index + i] = data[i]
	end
end

function EntityManager:buildQuery(components, componentsCount)
	local queryBuilder = self.EntityQueryBuilder
	local query = queryBuilder:withAll(components):build();
	return query
end

if Feint.ECS.FFI_OPTIMIZATIONS then
	function EntityManager:execute(arguments, archetype, callback)
		-- printf("Calling function on entities\n")
		local archetypeChunks = self.archetypeChunks
		local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
		local a3Name, a4Name = a3.Name, a4.Name

		for i = 1, self.archetypeChunksCount[archetype], 1 do
			local archetypeChunk = archetypeChunks[archetype][i]
			local idList = archetypeChunk.entityIndexToId
			local data = archetypeChunk.data

			-- printf("chunk %d: %s\n", i, archetypeChunk.data[19].Transform.x)
			for j = 0, archetypeChunk.numEntities - 1, 1 do
				-- printf("  x: %f\n  index: %s, id: %s\n", data[j][a4.Name].x, j, id)
				callback(data, idList[j + 1], data[j][a3Name], data[j][a4Name])
			end
		end
	end
else
	function EntityManager:execute(arguments, archetype, callback)
		-- printf("Calling function on entities\n")
		local archetypeChunks = self.archetypeChunks
		local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
		--local a1, a2, a3, a4, a5, a6 = arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]

		for i = 1, self.archetypeChunksCount[archetype], 1 do
			local archetypeChunk = archetypeChunks[archetype][i]
			local idList = archetypeChunk.entityIndexToId
			local data = archetypeChunk.data

			for j = 1, archetypeChunk.numEntities, 1 do
				local offset = (j - 1) * archetypeChunk.entitySize + 1
				-- callback(data, idList[j], offset, a3[1] + offset)
				callback(data, idList[j], offset, a3.size + offset)
			end											-- [1] is actually .size
		end
	end
end

local componentCache = {}
-- local argumentCache = {}
function EntityManager:forEach(id, callback)
	-- get the function arguments and store them as an array of strings
	if not componentCache[id] then
		componentCache[id] = {}
		-- argumentCache[id] = {}

		local funcInfo = debug.getinfo(callback)
		-- for k, v in pairs(funcInfo) do print(k, v) end
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

	local query = self:buildQuery(componentCache[id])
	query:getArchetypeChunks(self.archetypeChunks)

	-- convert the array of strings into an archetypeString
	local archetypeString = self:getArchetypeString(componentCache[id])
	-- use the string to execute the callback on its respective archetype chunks
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
