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
		-- the current archetypeChunk is assumed to be open
		if archetypeChunk:isFull() then	-- if it's full, create a new one
			archetypeChunk = self:newArchetypeChunk()
			printf("New ArchetypeChunk\n")
		end
	else
		archetypeChunk = self:newArchetypeChunk() -- lazily instantiate the first open archetype chunk
		printf("New ArchetypeChunk\n")
	end

	return archetypeChunk
end
function ArchetypeChunkGroup:createEntity(id)
	local archetypeChunk = self:getOpenArchetypeChunk()
	local index = archetypeChunk:newEntity(id)
	self.entities[id] = {archetypeChunk, index}

	-- self.archetypeChunkManager.entityIDToArchetypeChunkGroup[id] = self
	self.archetypeChunkManager:registerEntityWithArchetypeChunkGroup(id, self)
	return archetypeChunk, index
end
function ArchetypeChunkGroup:getArchetypeChunkFromId(id)
	-- TODO: use individual tables instead
	return self.entities[id][1], self.entities[id][2]
end
function ArchetypeChunkGroup:newArchetypeChunk()
	local archetypeChunk = EntityArchetypeChunk:new(self.archetype)
	self.archetypeChunks[#self.archetypeChunks + 1] = archetypeChunk
	return archetypeChunk
end

return ArchetypeChunkGroup
