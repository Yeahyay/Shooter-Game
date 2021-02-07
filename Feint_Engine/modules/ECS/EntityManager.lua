local EntityManager = {}

local Paths = Feint.Core.Paths

local EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
local EntityManagerArchetypeMethods = require(Paths.ECS .. "EntityManagerArchetypeMethods")
local EntityManagerExecuteFunctions = require(Paths.ECS .. "EntityManagerExecuteFunctions")

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
		elseif EntityManagerExecuteFunctions[k] then
			return EntityManagerExecuteFunctions[k]
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
	EntityManagerExecuteFunctions:load(self)

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

function EntityManager:createEntityFromArchetype(archetype)
	-- print(archetype)
	-- Feint.Log:logln("Creating entity from archetype ".. archetype.archetypeString)
	local archetypeChunk = self:getNextArchetypeChunk(archetype)
	assert(archetypeChunk)
	local id = self:getNewEntityId()
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
function EntityManager:buildQueryFromComponents(components, componentsCount)
	local queryBuilder = self.EntityQueryBuilder
	local query = queryBuilder:withAll(components):build();
	return query
end
function EntityManager:getEntitiesFromQuery(query)
	-- printf("Getting Entities from Query\n")
	local entities = {}
	return entities
end
-- Feint.Util.Memoize(EntityManager.getEntitiesFromQuery)


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
					assert(component, string.format("arg %d (%s) is not a component", i, componentName), 2)
					componentCache[id][i] = component
					componentCache[id].execute = self.executeEntityAndData

					i = i + 1
				end
			else
				componentCache[id][i] = componentName
				componentCache[id].execute = self["execute" .. funcInfo.nparams]
				i = i + 1
			end
		end
	end

	local query = self:buildQueryFromComponents(componentCache[id])
	query:getArchetypeChunks(self.archetypeChunks)

	-- convert the array of strings into an archetypeString
	local archetypeString = self:getArchetypeStringFromComponents(componentCache[id])
	-- use the string to execute the callback on its respective archetype chunks
	componentCache[id].execute(self, componentCache[id], self.archetypes[archetypeString], callback)

end
-- Feint.Util.Memoize(EntityManager.forEach)

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
