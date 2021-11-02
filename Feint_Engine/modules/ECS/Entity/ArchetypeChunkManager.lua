local EntityArchetype = Feint.ECS.EntityArchetype
local ArchetypeChunkGroup = require(Feint.Core.Paths.ECS_Entity .. "ArchetypeChunkGroup")

local ArchetypeChunkManager = {}
function ArchetypeChunkManager:new(...)
	local newManager = {}
	setmetatable(newManager, {
		__index = self;
		__tostring = function()
			return "ArchetypeChunkManager"
		end
	})
	newManager:init(...)
	return newManager
end
function ArchetypeChunkManager:init()
	self.archetypes = {
		size = 0
	}
	self.entityIDToArchetypeChunkGroup = {}
	local obj = {
		size = 0
	}
	local s = tostring(obj)
	self.archetypeChunkGroups = setmetatable(obj, {
		__newindex = function(self, k, v)
			if type(k) == "number" then
				error("archetypeChunkGroups are a hashmap only")
			end
			rawset(self, k, v)
		end;
		__tostring = function()
			return "ArchetypeChunkManager_EntityArchetypeChunkGroups: " .. s
		end
	})
end

function ArchetypeChunkManager:registerEntityWithArchetypeChunkGroup(entityID, archetypeChunkGroup)
	assert(entityID, "registerEntityWithArchetypeChunkGroup error: no id given", 2)
	assert(archetypeChunkGroup, "registerEntityWithArchetypeChunkGroup error: no archetypeChunkGroup given", 2)
	printf("registered entity (%s) to %q", entityID, tostring(archetypeChunkGroup))
	self.entityIDToArchetypeChunkGroup[entityID] = archetypeChunkGroup
end
function ArchetypeChunkManager:getArchetypeChunkGroupFromEntity(entityID)
	assert(entityID, "getArchetypeChunkGroupFromEntity error: no id given", 2)
	return self.entityIDToArchetypeChunkGroup[entityID]
end

-- ARCHETPYE GETTERS
function ArchetypeChunkManager:getArchetypeChunkFromId(id)
	local archetypeChunkGroup = self:getArchetypeChunkGroupFromEntity(id)
	assert(archetypeChunkGroup, "Something bad from id " .. tostring(id) .. " wtf")
	return archetypeChunkGroup:getArchetypeChunkFromId(id)
end

function ArchetypeChunkManager:addArchetypeChunkGroup(archetype)
	assert(not self.archetypeChunkGroups[archetype], "Archetype group " .. archetype.Name .. " already exists")
	self.archetypeChunkGroups[archetype] = ArchetypeChunkGroup:new(self, archetype)
	self.archetypeChunkGroups.size = self.archetypeChunkGroups.size + 1
	printf("Adding archetype chunk group %s\n", archetype.Name)
end

-- ARCHETYPE CONSTRUCTORS
function ArchetypeChunkManager:newArchetypeFromComponents(components)
	-- print("ArchetypeChunkManager:newArchetypeFromComponents(components)")
	local archetype = EntityArchetype:new(components)
	self.archetypes[archetype.signature] = archetype
	self.archetypes.size = self.archetypes.size + 1

	self:addArchetypeChunkGroup(archetype)
	return archetype
end

-- ARCHETPYE GETTERS
function ArchetypeChunkManager:getArchetypeFromComponents(components)
	-- print("ArchetypeChunkManager:getArchetypeSignatureFromComponents(components)")
	local archetypeSignature = EntityArchetype:getArchetypeSignatureFromComponents(components)
	local archetype = self:getArchetypeFromArchetypeSignature(archetypeSignature)
	if not archetype then
		-- printf("Archetype signature \"%s\" not found, creating\n", archetypeSignature:gsub("_signature", ""))
		archetype = self:newArchetypeFromComponents(components)
	end
	return archetype
end
function ArchetypeChunkManager:getArchetypeFromArchetypeSignature(signature)
	-- print("ArchetypeChunkManager:getArchetypeFromArchetypeSignature(signature)")
	return self.archetypes[signature]
end

-- ARCHETYPE SIGNATURE GETTERS
-- function ArchetypeChunkManager:getArchetypeSignatureFromComponents(components)
-- 	-- print("ArchetypeChunkManager:getArchetypeSignatureFromComponents(components)")
-- end

-- COMPONENT GETTERS
function ArchetypeChunkManager:getComponentsFromArchetype(archetype)
	-- print("ArchetypeChunkManager:getComponentsFromArchetype(archetype)")
	return archetype.components
end
function ArchetypeChunkManager:getComponentsFromArchetypeSignature(signature)
	-- print("ArchetypeChunkManager:getComponentsFromArchetypeSignature(signature)")
	return self:getComponentsFromArchetype(self:getArchetypeFromArchetypeSignature(signature))
end

-- ARCHETYPE CHUNK CONSTRUCTORS
-- function ArchetypeChunkManager:newArchetypeChunkFromArchetype(archetype)
-- 	print("ArchetypeChunkManager:newArchetypeChunkFromArchetype(archetype)")
-- end
-- function ArchetypeChunkManager:newArchetypeChunkFromSignature(signature)
-- 	print("ArchetypeChunkManager:newArchetypeChunkFromSignature(signature)")
-- end
-- function ArchetypeChunkManager:newArchetypeChunkFromComponents(components)
-- 	print("ArchetypeChunkManager:newArchetypeChunkFromComponents(components)")
-- end

-- ARCHETYPE CHUNK GROUP GETTERS
function ArchetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)
	-- print("ArchetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)")
	-- local archetypeChunkGroup = self.archetypeChunkGroups[archetype]
	assert(archetype, "No archetype given", 2)
	assert(self.archetypeChunkGroups[archetype], "Archetype " .. tostring(archetype) .. " is not registered")
	return self.archetypeChunkGroups[archetype]--- archetypeChunkGroup:getOpenArchetypeChunk()
end
function ArchetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(signature)
	-- print("ArchetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(signature)")
	return self:getArchetypeChunkGroupFromArchetype(self:getArchetypeFromArchetypeSignature(signature))
end
function ArchetypeChunkManager:getArchetypeChunkGroupFromComponents(components)
	-- print("ArchetypeChunkManager:getArchetypeChunkGroupFromComponents(components)")
	return self:getArchetypeChunkGroupFromArchetype(self:getArchetypeFromComponents(components))
end

function ArchetypeChunkManager:queryArchetypeChunksForEntity(id)
	print("ArchetypeChunkManager:queryArchetypeChunksForEntity(id)")
end

function ArchetypeChunkManager:queryArchetypeChunkEntityIndexFromEntity(id)
	-- entities are stored unorderd in a two-way mapped list, therefore, an entity's id is not the index it belongs in
	print("ArchetypeChunkManager:queryArchetypeChunkEntityIndexFromEntity(id)")
end


return ArchetypeChunkManager
