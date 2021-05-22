local EntityManager = {}

local Paths = Feint.Core.Paths

local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
local EntityArchetype = Feint.ECS.EntityArchetype
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

	self.forEachNotParallel_Queue = {
		items = {};
		push = function(self, jobData)
			self.items[#self.items + 1] = jobData
		end;
		pop = function(self)
			local job = self.items[#self.items]
			self.items[#self.items] = nil
			return job
		end;
		empty = function(self)
			return #self.items <= 0
		end
	}

	self.archetypeChunkManager = ArchetypeChunkManager:new()

	ExecuteFunctions:load(self)
	EntityQueryBuilderAPI:load(self)

	self.forEachJobs = {}

	self.EntityQueryBuilder = EntityQueryBuilder:new()
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
	-- id = self.entitiesCount
	-- return id

	-- repeat
	-- 	id = math.floor(love.math.random() * 100000000)
	-- until not self.entities[id]
	-- return id --self.entitiesCount --newID

	-- local s = {}
	-- for i = 1, 24, 1 do
	-- 	local r = love.math.random(33, 126)
	-- 	s[#s + 1] = string.char(r)
	-- end
	-- id = table.concat(s)
	-- return id

	id = Feint.Util.UUID.new()
	return id
end

function EntityManager:createEntity(archetypeChunkGroup)
	assert(archetypeChunkGroup)
	local id = self:getNewEntityId()
	-- assosciate the entity id with its respective chunk
	local archetypeChunk = archetypeChunkGroup:createEntity(id)
	self.entities[id] = {archetypeChunk, archetypeChunk:getEntityIndexFromID(id)}
	return id
end
function EntityManager:createEntityFromArchetype(archetype)
	assert(archetype, "no archetype given", 2)
	assert(archetype.name == "EntityArchetype", "not given an EntityArchetype")

	local archetypeChunkGroup = self.archetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)

	-- local archetypeChunk = archetypeChunkGroup:getOpenArchetypeChunk()
	return self:createEntity(archetypeChunkGroup)
end
function EntityManager:createEntityFromArchetypeSignature(signature)

end
function EntityManager:createEntityFromComponents(components)
	assert(components, "argument components is nil", 2)
	assert(type(components) == "table", "components need to be in a table", 2)
	assert(#components > 0, "no components given", 2)

	local archetypeChunkGroup = self.archetypeChunkManager:getArchetypeChunkGroupFromComponents(components)
	return self:createEntity(archetypeChunkGroup)
end
function EntityManager:getEntityDataFromID(entityID)
	local archetypeChunk, index = self:getArchetypeChunkFromEntity(entityID)
	return self:getEntityDataFromArchetypeChunk(archetypeChunk, entityID), archetypeChunk.archetype, index
end
function EntityManager:getEntityDataFromArchetypeChunk(archetypeChunk, entityID)
	return archetypeChunk:getDataArray()[archetypeChunk:getEntityIndexFromID(entityID) - 1]
end

-- WRAPPERS
function EntityManager:getArchetypeChunkFromEntity(id)
	return self.archetypeChunkManager:getArchetypeChunkFromId(id)
end
function EntityManager:newArchetypeFromComponents(components)
	return self.archetypeChunkManager:newArchetypeFromComponents(components)
end

function EntityManager:getEntityCount()
	local count = 0
	for k, archetypeChunkGroup in pairs(self.archetypeChunkManager.archetypeChunkGroups) do
		if k == "size" then goto continue end
		for index, archetypeChunk in pairs(archetypeChunkGroup:getArchetypeChunks()) do
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

		if funcInfo.nparams == 1 or (self.World.components[debug.getlocal(callback, 2)] and funcInfo.nparams >= 2) then
			for j = 1, funcInfo.nparams, 1 do
				local argument = debug.getlocal(callback, j)
				argumentCache[id][j] = argument
			end
		else
			argumentCache[id][1] = "NOARG"
		end

		argumentCache[id].info = funcInfo
		local _, source = debug.getlocal(4, 1)
		argumentCache[id].Source = source.Name
	end
end

local queueCache = {}
function EntityManager:preQueue(id, callback)
	assert(id, "No id given", 2)
	assert(callback, "No callback given", 2)
	assert(type(callback) == "function", "callback is not a function")

	if not queueCache[id] then
		local func = callback() -- get the execute function from the callback
		self:cacheArguments(id, func)

		queueCache[id] = {}
		local currentQueue = queueCache[id]

		currentQueue.id = id
		currentQueue.func = func

		currentQueue.source = argumentCache[id].Source

		currentQueue.startTime = 0
		currentQueue.endTime = 0
		currentQueue.runTime = 0

		local arguments = self:argumentsToComponents(id, func)
		currentQueue.componentArguments = arguments.componentArguments
		currentQueue.extraArguments = arguments.extraArguments
		currentQueue.arguments = arguments.all

		local queryBuilder = self.EntityQueryBuilder
		currentQueue.query = queryBuilder:withAll(arguments.componentArguments):build()

		-- convert the array of strings into an archetypeSignature
		currentQueue.signature = EntityArchetype:getArchetypeSignatureFromComponents(currentQueue.componentArguments)
		assert(currentQueue.signature, "pre queue failed to get archetype string")
		currentQueue.archetype = self.archetypeChunkManager:getArchetypeFromComponents(currentQueue.componentArguments)
		assert(currentQueue.archetype, "pre queue failed to get archetype \"" .. tostring(currentQueue.archetype) .. "\"")

		if argumentCache[id][1] == "NOARG" then
			currentQueue.execute = ExecuteFunctions.noarg
		else
			currentQueue.execute = ExecuteFunctions:getExecuteFunction(#currentQueue.componentArguments)
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

function EntityManager:forEachNotParallel_enqueue(id, callback)
	assert(id, "No id given", 2)
	assert(callback, "No callback given", 2)
	assert(type(callback) == "function", "callback is not a function")

	self.forEachNotParallel_Queue:push(self:preQueue(id, callback))
end

function EntityManager:executeJob(jobData)
	assert(jobData, "no job data given")
	local archetypeChunks = jobData.query:getArchetypeChunks(jobData.query, self)

	jobData.startTime = love.timer.getTime()
	local status, message = pcall(function()
		local status = jobData.execute(self, jobData.source, jobData.componentArguments, jobData.archetype, archetypeChunks, jobData.func)
		assert(status == 0)
	end)
	if not status then
		error(message, 2)
		Feint.Core.Time:pause()
	end
	jobData.endTime = love.timer.getTime()
	jobData.runTime = jobData.endTime - jobData.startTime

end

function EntityManager:update(dt)
	self:forEachNotParallel_execute(dt)
end

function EntityManager:forEachNotParallel_execute(dt)
	while not self.forEachNotParallel_Queue:empty() do
		local job = self.forEachNotParallel_Queue:pop()
		self:executeJob(job)
	end
end

function EntityManager:forEachNotParallel(id, callback)
	self:forEachNotParallel_enqueue(id, callback)
end

function EntityManager:forEachNotParallel_OLD(id, callback)
	assert(id, "No id given", 2)
	assert(callback, "No callback given", 2)
	assert(type(callback) == "function", "callback is not a function")

	local func = callback()
	local preQueueData = self:preQueue(id, func)

	local query = self:buildQueryFromComponents(preQueueData.componentArguments)
	local archetypeChunks = query:getArchetypeChunks(self)

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
end
-- Feint.Util.Memoize(EntityManager.forEach)

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
