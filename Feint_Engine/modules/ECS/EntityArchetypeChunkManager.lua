local EntityArchetype = Feint.ECS.EntityArchetype
local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk

local ArchetypeChunkGroup = {}
function ArchetypeChunkGroup:new(...)
	local newGroup = {}
	local s = tostring(newGroup)
	setmetatable(newGroup, {
		__index = self;
		__tostring = function()
			return "EntityArchetypeChunkGroup: " .. s
		end
	})
	newGroup:init(...)
	return newGroup
end
function ArchetypeChunkGroup:init(chunkManager, archetype)
	assert(archetype, "ArchetypeChunkGroup needs an archetype")
	self.entities = {}
	self.archetypeChunkManager = chunkManager
	self.archetypeChunks = setmetatable({}, {
		__newindex = function(self, k, v)
			assert(type(k) == "number", "archetypeChunks are an array only")
			rawset(self, k, v)
		end;
		__tostring = function()
			return "EntityArchetypeChunkGroup_ArchetypeChunks"
		end
	})
	self.archetype = archetype
end
function ArchetypeChunkGroup:getArchetypeChunk(index)
	assert(index > 0 and index <= #self.archetypeChunks, "given ArchetypeChunk index " .. index .. "out of range")
	return self.archetypeChunks[index]
end
function ArchetypeChunkGroup:getArchetypeChunks()
	return self.archetypeChunks
end
function ArchetypeChunkGroup:getOpenArchetypeChunk()
	local archetypeChunk
	if #self.archetypeChunks > 0 then
		archetypeChunk = self.archetypeChunks[#self.archetypeChunks]
		if archetypeChunk:isFull() then
			archetypeChunk = self:newArchetypeChunk()
		end
	else
		archetypeChunk = self:newArchetypeChunk()
	end

	return archetypeChunk
end
function ArchetypeChunkGroup:createEntity(id)
	local archetypeChunk = self:getOpenArchetypeChunk()
	local index = archetypeChunk:newEntity(id)
	self.entities[id] = {archetypeChunk, index}

	self.archetypeChunkManager.entities[id] = self
	return archetypeChunk, index
end
function ArchetypeChunkGroup:getArchetypeChunkFromId(id)
	return self.entities[id][1], self.entities[id][2]
end
function ArchetypeChunkGroup:newArchetypeChunk()
	local archetypeChunk = EntityArchetypeChunk:new(self.archetype)
	self.archetypeChunks[#self.archetypeChunks + 1] = archetypeChunk
	return archetypeChunk
end

local entityArchetypeChunkManager = {}
function entityArchetypeChunkManager:new(...)
	local newManager = {}
	setmetatable(newManager, {
		__index = self;
		__tostring = function()
			return "EntityArchetypeChunkManager"
		end
	})
	newManager:init(...)
	return newManager
end
function entityArchetypeChunkManager:init()
	self.archetypes = {size = 0}
	self.entities = {}
	local t = {size = 0}
	local s = tostring(t)
	self.archetypeChunkGroups = setmetatable(t, {
		-- __index = self;
		__newindex = function(self, k, v)
			if type(k) == "number" then
				error("archetypeChunkGroups are a hashmap only")
			end
			rawset(self, k, v)
		end;
		__tostring = function()
			return "EntityArchetypeChunkManager_EntityArchetypeChunkGroups: " .. s
		end
	})
end

-- ARCHETPYE GETTERS
function entityArchetypeChunkManager:getArchetypeChunkFromId(id)
	local archetypeChunkGroup = self.entities[id]
	return archetypeChunkGroup:getArchetypeChunkFromId(id)
end

function entityArchetypeChunkManager:addArchetypeChunkGroup(archetype)
	assert(not self.archetypeChunkGroups[archetype], "Archetype group " .. archetype.Name .. " already exists")
	self.archetypeChunkGroups[archetype] = ArchetypeChunkGroup:new(self, archetype)
	self.archetypeChunkGroups.size = self.archetypeChunkGroups.size + 1
	printf("Adding archetype chunk group %s\n", archetype.Name)
end

-- ARCHETYPE CONSTRUCTORS
function entityArchetypeChunkManager:newArchetypeFromComponents(components)
	-- print("EntityArchetypeChunkManager:newArchetypeFromComponents(components)")
	local archetype = EntityArchetype:new(components)
	self.archetypes[archetype.signature] = archetype
	self.archetypes.size = self.archetypes.size + 1

	self:addArchetypeChunkGroup(archetype)
	return archetype
end

-- ARCHETPYE GETTERS
function entityArchetypeChunkManager:getArchetypeFromComponents(components)
	-- print("EntityArchetypeChunkManager:getArchetypeSignatureFromComponents(components)")
	local archetypeSignature = EntityArchetype:getArchetypeSignatureFromComponents(components)
	local archetype = self:getArchetypeFromArchetypeSignature(archetypeSignature)
	if not archetype then
		printf("Archetype signature \"%s\" not found, creating\n", archetypeSignature:gsub("_signature", ""))
		archetype = self:newArchetypeFromComponents(components)
	end
	return archetype
end
function entityArchetypeChunkManager:getArchetypeFromArchetypeSignature(signature)
	-- print("entityArchetypeChunkManager:getArchetypeFromArchetypeSignature(signature)")
	return self.archetypes[signature]
end

-- ARCHETYPE SIGNATURE GETTERS
-- function entityArchetypeChunkManager:getArchetypeSignatureFromComponents(components)
-- 	-- print("entityArchetypeChunkManager:getArchetypeSignatureFromComponents(components)")
-- end

-- COMPONENT GETTERS
function entityArchetypeChunkManager:getComponentsFromArchetype(archetype)
	-- print("entityArchetypeChunkManager:getComponentsFromArchetype(archetype)")
	return archetype.components
end
function entityArchetypeChunkManager:getComponentsFromArchetypeSignature(signature)
	-- print("entityArchetypeChunkManager:getComponentsFromArchetypeSignature(signature)")
	return self:getComponentsFromArchetype(self:getArchetypeFromArchetypeSignature(signature))
end

-- ARCHETYPE CHUNK CONSTRUCTORS
-- function entityArchetypeChunkManager:newArchetypeChunkFromArchetype(archetype)
-- 	print("entityArchetypeChunkManager:newArchetypeChunkFromArchetype(archetype)")
-- end
-- function entityArchetypeChunkManager:newArchetypeChunkFromSignature(signature)
-- 	print("entityArchetypeChunkManager:newArchetypeChunkFromSignature(signature)")
-- end
-- function entityArchetypeChunkManager:newArchetypeChunkFromComponents(components)
-- 	print("entityArchetypeChunkManager:newArchetypeChunkFromComponents(components)")
-- end

-- ARCHETYPE CHUNK GROUP GETTERS
function entityArchetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)
	-- print("entityArchetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)")
	-- local archetypeChunkGroup = self.archetypeChunkGroups[archetype]
	assert(archetype, "No archetype given", 2)
	assert(self.archetypeChunkGroups[archetype], "Archetype " .. tostring(archetype) .. " is not registered")
	return self.archetypeChunkGroups[archetype]--- archetypeChunkGroup:getOpenArchetypeChunk()
end
function entityArchetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(signature)
	-- print("entityArchetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(signature)")
	return self:getArchetypeChunkGroupFromArchetype(self:getArchetypeFromArchetypeSignature(signature))
end
function entityArchetypeChunkManager:getArchetypeChunkGroupFromComponents(components)
	-- print("entityArchetypeChunkManager:getArchetypeChunkGroupFromComponents(components)")
	return self:getArchetypeChunkGroupFromArchetype(self:getArchetypeFromComponents(components))
end

function entityArchetypeChunkManager:queryArchetypeChunksForEntity(id)
	print("entityArchetypeChunkManager:queryArchetypeChunksForEntity(id)")
end

function entityArchetypeChunkManager:queryArchetypeChunkEntityIndexFromEntity(id)
	-- entities are stored unorderd in a two-way mapped list, therefore, an entity's id is not the index it belongs in
	print("entityArchetypeChunkManager:queryArchetypeChunkEntityIndexFromEntity(id)")
end


return entityArchetypeChunkManager
