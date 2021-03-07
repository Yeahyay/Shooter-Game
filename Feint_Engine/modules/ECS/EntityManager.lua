local EntityManager = {}

local Paths = Feint.Core.Paths

local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
local EntityManagerArchetypeMethods = require(Paths.ECS .. "EntityManagerArchetypeMethods")
local ExecuteFunctions = require(Paths.ECS .. "EntityManagerExecuteFunctions")
local EntityQueryBuilderAPI = require(Paths.ECS .. "EntityManagerQueryBuilder")

function EntityManager:new(...)
	local object = {}
	setmetatable(object, {
		__index = self
	})
	object.init(object, ...)
	return object
end
setmetatable(EntityManager, {
	__index = function(t, k)
		if rawget(t, k) then
			return rawget(t, k)
		elseif EntityManagerArchetypeMethods[k] then
			return EntityManagerArchetypeMethods[k]
		elseif EntityQueryBuilderAPI[k] then
			return EntityQueryBuilderAPI[k]
		end
	end
})

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

	EntityManagerArchetypeMethods:load(self)
	ExecuteFunctions:load(self)
	EntityQueryBuilderAPI:load(self)

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
	return math.floor(love.math.random() * 100000000) --self.entitiesCount --newID
end

function EntityManager:createEntityFromArchetype(archetype)
	-- print(archetype)
	-- Feint.Log:logln("Creating entity from archetype ".. archetype.archetypeString)
	local archetypeChunk = self:getNextArchetypeChunk(archetype)
	assert(archetypeChunk)
	local id
	repeat
		id = self:getNewEntityId()
	until not archetypeChunk.entityIdToIndex[id]
	assert(id)
	-- assosciate the entity id with its respective chunk
	self.entities[id] = {archetypeChunk, archetypeChunk.entityIdToIndex[id]}
	archetypeChunk:newEntity(id)
	return id
end

function EntityManager:removeEntity(id)
	self.entityIds[id] = nil
end

function EntityManager:setComponentData(entity, component, data)
	local archetypeChunk = self:getArchetypeChunkFromEntity(entity)
	print(archetypeChunk.data)
	for i = 1, archetypeChunk.numEntities, 1 do
		for k, v in pairs(archetypeChunk.archetype.components) do
			print(archetypeChunk.data)
		end
	end
	print(entity)
	for k, v in pairs(self.entities[entity]) do
		print(k, v)
	end
	local index = self:getArchetypeChunkEntityIndexFromEntity(entity)
	local archetypeChunkData = archetypeChunk.data
	-- local offset =
	for i = 1, #data, 1 do
		archetypeChunkData[index + i] = data[i]
	end
end

-- QUERY BUILDER API
-- Feint.Util.Memoize(EntityManager.getEntitiesFromQuery)

local argumentCache = {}
local function cacheArguments(id, callback)
	assert(id, "missing id")
	-- get the function arguments and store them as an array of strings
	if not argumentCache[id] then
		assert(callback, "missing callback")
		argumentCache[id] = {}

		local func = callback() -- get the execute function from the callback
		local funcInfo = debug.getinfo(func)

		if funcInfo.nparams > 0 then
			for j = 1, funcInfo.nparams, 1 do
				local argument = debug.getlocal(func, j)
				argumentCache[id][j] = argument
			end
		else
			argumentCache[id][1] = "NOARG"
		end
	end
end

local queueCache = {}
function EntityManager:preQueue2(id, callback)
	if not queueCache[id] then
		cacheArguments(id, callback)

		queueCache[id] = {}
		local currentQueue = queueCache[id]

		currentQueue.id = id
		currentQueue.startTime = 0
		currentQueue.endTime = 0
		currentQueue.runTime = 0

		currentQueue.componentArguments = self:argumentsToComponents2(id, callback)

		-- convert the array of strings into an archetypeString
		currentQueue.archetypeString = self:getArchetypeStringFromComponents(currentQueue.componentArguments)
		currentQueue.archetype = self.archetypes[currentQueue.archetypeString]

		-- print(argumentCache[id][1], "kokpmkl")
		if currentQueue.componentArguments[1] == "Data" and currentQueue.componentArguments[2] == "Entity" then
			currentQueue.execute = ExecuteFunctions.executeEntity2
		elseif argumentCache[id][1] == "NOARG" then
			currentQueue.execute = ExecuteFunctions.noarg
		else
			currentQueue.execute = ExecuteFunctions["execute" .. #currentQueue.componentArguments]
		end
	end
	return queueCache[id]
end
function EntityManager:argumentsToComponents2(id, callback)
	local componentArguments = {}

	-- uses the cached function arguments to find their respective components
	local cachedArguments = argumentCache[id]
	for i = 1, #cachedArguments, 1 do
		local argument = cachedArguments[i]
		if argument == "NOARG" then
			componentArguments[1] = "NOARG"
			break
		end
		if argument ~= "Data" and argument ~= "Entity" then
			assert(self.World.components[argument], "component " .. argument .. " is not registered")
			local component = self.World.components[argument]
			if component.componentData then
				assert(component, string.format("arg %d (%s) is not a component", i, argument), 2)
				componentArguments[i] = component
			end
		else
			componentArguments[i] = argument
		end
	end
	return componentArguments
end
function EntityManager:getQueueCacheDebug()
	return queueCache
end
function EntityManager:getEntityCount()
	local count = 0
	for k, archetypeChunkTable in pairs(self.archetypeChunks) do
		for index, archetypeChunk in pairs(archetypeChunkTable) do
			-- print(index, archetypeChunk, archetypeChunk.numEntities)
			count = count + archetypeChunk.numEntities
		end
	end
	return count
end

function EntityManager:forEachNotParallel2(id, callback)
	local preQueueData = self:preQueue2(id, callback)

	local query = self:buildQueryFromComponents(preQueueData.componentArguments)
	query:getArchetypeChunks(self.archetypeChunks)

	-- Feint.Util.Debug.DEBUG_PRINT_TABLE(preQueueData)

	preQueueData.startTime = love.timer.getTime()
	preQueueData.execute(self, preQueueData.componentArguments, preQueueData.archetype, callback)
	preQueueData.endTime = love.timer.getTime()
	preQueueData.runTime = preQueueData.endTime - preQueueData.startTime


	-- for _, archetypeChunk in pairs(self:getArchetypeChunkTableFromString(archetypeString)) do
	-- 	Feint.Core.Thread:queue(self, archetypeChunk, preQueueData.arguments, jobData, callback)
	-- end
	-- Feint.Core.Thread:queue(self.archetypeChunks[archetypeString], self.archetypes[archetypeString], callback)

end
-- Feint.Util.Memoize(EntityManager.forEach)

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
