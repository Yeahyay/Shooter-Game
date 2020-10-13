local ECSUtils = Feint.ECS.Util

local EntityManager = ECSUtils.newClass("EntityManager")
local EntityArchetype = Feint.ECS.EntityArchetype
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
	self.EntityQueryBuilder = Feint.ECS.EntityQueryBuilder
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
EntityManager.CreateEntity = Feint.Util.Memoize(EntityManager.CreateEntity)

function EntityManager:newArchetype(components)
	local archetype = EntityArchetype:new("?", components)
	self.archetypes[archetype.Name] = archetype
	return archetype
end

-- local function getEntity()
-- 	local entity = nil
-- 	return entity
-- end

local getEntities = Feint.Util.Memoize(function(query)
	printf("Getting Entities from Query\n")
	local entities = {}
	return entities
end)

local generateQuery = --Feint.Util.Memoize
(function(components, componentsCount)
	-- print(components, componentsCount)
	-- printf("Generating EntityQuery for components: ")

	for i = 1, componentsCount - 1, 1 do
		local componentData = components[i]
		local name = componentData.Name
		if name == "Entity" then
			goto forEnd
		end

		-- assert(components[i] ~= nil, string.format("Component %d does not exist\n", i))
		-- printf("%s, ", components[i].Name or "nonexistent")
		::forEnd::
	end

	-- assert(components[#components] ~= nil, string.format("Component %d does not exist\n", #components))
	-- if #components > 0 then
	-- 	printf("%s\n", components[#components].Name or "nonexistent")
	-- end

	local query = nil
	return query
end)

local execute = function(entities, callback)
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
	-- printf("forEach from System \"%s\"\n", system.Name)

	local startTime = getTime()
	local query = nil

	for i = 1, 1, 1 do
		lx, ly = px, py
		-- generate an entity query that fits the specified arguments
		query = generateQuery(arguments, #arguments)

		px, py = input.mouse.PositionRaw.x - 50 / 2, input.mouse.PositionRaw.y + 50 / 2
		Feint.Graphics.rectangle(lx, ly, 0, "fill", px, py, 50, 50)
	end

	local endTime = getTime() - startTime
	-- printf("TIME: %fs, %f frames\n", endTime, endTime * 60)
	avg = avg + endTime
	avgTimes = avgTimes + 1
	-- printf("AVG: %fs; %f frames\n", avg / avgTimes, endTime * 60)

	execute(getEntities(query), callback)
	-- printf("Finished forEach\n")
end

function EntityManager:removeEntity(id)
	self.entityIds[id] = nil
end

Feint.Util.Table.makeTableReadOnly(EntityManager, function(self, k)
	return string.format("attempt to modify %s", EntityManager.Name)
end)
return EntityManager
