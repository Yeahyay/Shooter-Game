local EntityManager = {}

local Paths = Feint.Core.Paths

local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
local EntityArchetype = Feint.ECS.EntityArchetype
-- local ArchetypeMethods = require(Paths.ECS .. "EntityManagerArchetypeMethods")
local ExecuteFunctions = require(Paths.ECS .. "EntityManagerExecuteFunctions")
local EntityQueryBuilderAPI = require(Paths.ECS .. "EntityManagerQueryBuilder")
local ArchetypeChunkManager = Feint.ECS.EntityArchetypeChunkManager

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
		-- elseif ArchetypeMethods[k] then
		-- 	return ArchetypeMethods[k]
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

	-- self.archetypes = setmetatable({}, {__index = {size = 0}}) -- all entity archetypes
	-- self.archetypeCount = 0
	-- self.archetypeChunks = {} -- a hash table of a list of archetype chunks
	self.archetypeChunkManager = ArchetypeChunkManager:new()
	-- self.archetypeChunksCount = {}
	-- self.archetypeChunksOpenStacks = setmetatable({}, {__mode = "k, v"}) -- queue of open archetype chunks

	-- ArchetypeMethods:load(self)
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

	local id
	repeat
		id = math.floor(love.math.random() * 100000000)
	until not self.entities[id]
	return id --self.entitiesCount --newID
end

function EntityManager:createEntity(archetypeChunk)
	assert(archetypeChunk)
	-- print(archetypeChunk.numEntities)
	-- local id
	-- repeat
	-- 	id = self:getNewEntityId()
	-- until not archetypeChunk.entityIdToIndex[id]
	-- assert(id)
	local id = self:getNewEntityId()
	-- assosciate the entity id with its respective chunk
	self.entities[id] = {archetypeChunk, archetypeChunk.entityIdToIndex[id]}
	archetypeChunk:newEntity(id)
return id

end
function EntityManager:createEntityFromArchetype(archetype)
	assert(archetype, "no archetype given", 2)
	assert(archetype.name == "EntityArchetype", "not given an EntityArchetype")

	-- Feint.Log:logln("Creating entity from archetype " .. archetype.signature)
	local archetypeChunkGroup = self.archetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)
	-- print(archetypeChunkGroup.archetype)
	local archetypeChunk = archetypeChunkGroup:getOpenArchetypeChunk()
	return self:createEntity(archetypeChunk)
end
function EntityManager:createEntityFromArchetypeSignature(signature)

end
function EntityManager:createEntityFromComponents(components)
	assert(components, "argument components is nil", 2)
	assert(type(components) == "table", "components need to be in a table", 2)
	assert(#components > 0, "no components given", 2)

	local archetypeChunkGroup = self.archetypeChunkManager:getArchetypeChunkGroupFromComponents(components)
	local archetypeChunk = archetypeChunkGroup:getOpenArchetypeChunk()
	return self:createEntity(archetypeChunk)
end

-- WRAPPERS
function EntityManager:newArchetypeFromComponents(components)
	return self.archetypeChunkManager:newArchetypeFromComponents(components)
end

--[[
function EntityManager:createEntityFromArchetype(archetype)
	-- print(archetype)
	-- Feint.Log:logln("Creating entity from archetype ".. archetype.signature)
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

--]]

function EntityManager:getEntityCount()
	local count = 0
	-- print(self.archetypeChunkManager.archetypeChunkGroups, "in90jionj9-0ikoio", "\n\n\n\n")
	for k, archetypeChunkGroup in pairs(self.archetypeChunkManager.archetypeChunkGroups) do
		if k == "size" then goto continue end
		for index, archetypeChunk in pairs(archetypeChunkGroup:getArchetypeChunks()) do
			-- print(index, archetypeChunk, archetypeChunk.numEntities)
			count = count + archetypeChunk.numEntities
		end
		::continue::
	end
	return count
end

local argumentCache = {}
function EntityManager:cacheArguments(id, callback)
	assert(id, "missing id")
	-- get the function arguments and store them as an array of strings
	if not argumentCache[id] then
		assert(callback, "missing callback")
		argumentCache[id] = {}

		local funcInfo = debug.getinfo(callback)

		-- print(self.World.components[debug.getlocal(callback, 2)], debug.getlocal(callback, 2), "knomknjopk")
		if funcInfo.nparams == 1 or (self.World.components[debug.getlocal(callback, 2)] and funcInfo.nparams >= 2) then
			for j = 1, funcInfo.nparams, 1 do
				local argument = debug.getlocal(callback, j)
				argumentCache[id][j] = argument
			end
		else
			argumentCache[id][1] = "NOARG"
		end

		argumentCache[id].info = funcInfo
		-- for k, v in pairs(getfenv(4)) do
		-- 	print(k, v)
		-- end
		-- local _, systems = debug.getlocal(5, 3)
		-- local _, index = debug.getlocal(5, 5)
		local _, source = debug.getlocal(4, 1)
		argumentCache[id].Source = source.Name
		-- print(systems[index])
		-- print(debug.getlocal(4, 1))
		-- print("saidmk", debug.getlocal(5, 3), debug.getlocal(5, 5))
		-- for k, v in pairs(debug.getinfo(5, "n")) do
		-- 	print(k, v)
		-- end
	end
end

local queueCache = {}
function EntityManager:preQueue(id, func)
	assert(id, "No id given", 2)
	assert(func, "No callback given", 2)
	assert(type(func) == "function", "callback is not a function")

	if not queueCache[id] then
		-- local func = callback() -- get the execute function from the callback
		self:cacheArguments(id, func)

		queueCache[id] = {}
		local currentQueue = queueCache[id]

		currentQueue.source = argumentCache[id].Source

		currentQueue.id = id
		currentQueue.startTime = 0
		currentQueue.endTime = 0
		currentQueue.runTime = 0

		local arguments = self:argumentsToComponents(id, func)
		currentQueue.componentArguments = arguments.componentArguments
		currentQueue.extraArguments = arguments.extraArguments
		currentQueue.arguments = arguments.all

		-- convert the array of strings into an archetypeSignature
		currentQueue.signature = EntityArchetype:getArchetypeSignatureFromComponents(currentQueue.componentArguments)
		assert(currentQueue.signature, "pre queue failed to get archetype string")
		currentQueue.archetype = self.archetypeChunkManager:getArchetypeFromComponents(currentQueue.componentArguments)--self.archetypes[currentQueue.signature]
		assert(currentQueue.archetype, "pre queue failed to get archetype \"" .. tostring(currentQueue.archetype) .. "\"")

		-- if currentQueue.componentArguments[1] == "Data" and currentQueue.componentArguments[2] == "Entity" then
		-- 	currentQueue.execute = ExecuteFunctions.executeEntity2
		-- else
		if argumentCache[id][1] == "NOARG" then
			currentQueue.execute = ExecuteFunctions.noarg
		else
			-- currentQueue.execute = ExecuteFunctions["execute" .. #currentQueue.componentArguments]
			currentQueue.execute = ExecuteFunctions:getExecuteFunction(#currentQueue.componentArguments)
			-- for k, v in pairs(ExecuteFunctions) do
			-- 	print(k, v)
			-- end
		end
	end
	return queueCache[id]
end
function EntityManager:argumentsToComponents(id, callback)
	assert(id, "No id given", 2)
	assert(callback, "No callback given", 2)
	assert(type(callback) == "function", "callback is not a function")

	local componentArguments = {}
	local extraArgs = {}
	local all = {}

	local uniqueComponents ={}

	-- uses the cached function arguments to find their respective components
	local cachedArguments = argumentCache[id]
	local j = 1
	local k = 1
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
				componentArguments[j] = component
				all[i] = component

				assert(not uniqueComponents[component], "given duplicate component " .. component.Name, 2)
				uniqueComponents[component] = true
			end
			j = j + 1
		else
			extraArgs[k] = argument
			all[i] = argument
			k = k + 1
		end
	end
	return {componentArguments = componentArguments, extraArguments = extraArgs, all = all}
end
function EntityManager:getQueueCacheDebug()
	return queueCache
end

function EntityManager:forEachNotParallel(id, callback)
	assert(id, "No id given", 2)
	assert(callback, "No callback given", 2)
	assert(type(callback) == "function", "callback is not a function")

	local func = callback()
	local preQueueData = self:preQueue(id, func)

	local query = self:buildQueryFromComponents(preQueueData.componentArguments)
	local archetypeChunks = query:getArchetypeChunks(self)

	-- print(id, #archetypeChunks)

	-- Feint.Util.Debug.DEBUG_PRINT_TABLE(preQueueData)

	preQueueData.startTime = love.timer.getTime()
	local status, message = pcall(function()
		local status = preQueueData.execute(self, preQueueData.source, preQueueData.componentArguments, preQueueData.archetype, archetypeChunks, func)
		assert(status == 0)
	end)
	if not status then
		error(message)
		Feint.Core.Time:pause()
	end
	preQueueData.endTime = love.timer.getTime()
	preQueueData.runTime = preQueueData.endTime - preQueueData.startTime
	-- print('komkl')
end
-- Feint.Util.Memoize(EntityManager.forEach)

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
