local ECSutils = Feint.ECS.Util

local EntityChunk = ECSutils.newClass("EntityChunk")
function EntityChunk:init(archetype, ...)
	assert(Feint.Util.Core.type(archetype) == "table", 1, "EntityArchetypeChunk needs an archetype")
	self.archetype = archetype
	self.Name = archetype.Name.."_ArchetypeChunk"
	self.isFull_cached = false

	self.capacity = 1024 - 2
	self.capacityBytes = 131072 - 40
	self.numEntities = 0
	self.data = Feint.Util.Table.preallocate(self.capacity * self.archetype.totalSize, 0)
	self.dataStatus = {}
	self.dataAlive = 0

	self.entitySize = self.archetype.totalSize
	self.entitySizeBytes = self.archetype.totalSizeBytes

	self.entityIdToIndex = {}
	self.entityIndexToId = {}

	self:preallocate(64)

	-- self.dead = false

	self.archetype.chunkCount = self.archetype.chunkCount + 1
	self.index = self.archetype.chunkCount
	self.id = string.format("%s_chunk%02d", self.archetype.archetypeString, self.index)
end
function EntityChunk:remove()
	self.archetype.chunkCount = self.archetype.chunkCount - 1
	for k, v in pairs(self) do
		self[k] = nil
	end
	-- self.dead = true
end
function EntityChunk:isFull()
	return self.numEntities * self.entitySizeBytes >= self.capacityBytes - self.entitySizeBytes
end
function EntityChunk:isEmpty()
	return self.numEntities <= 0
end
-- function EntityChunk:getEntity()
function EntityChunk:newEntity(id)
	if not self:isFull() then
		assert(type(id) == "number" and id >= 0, 3, "new entity expects a number")
		local dataOffset = self.numEntities * self.entitySize
		for archetyeComponentIndex = 1, #self.archetype.components, 1 do
			local component = self.archetype.components[archetyeComponentIndex]
			-- Feint.Log.log("Allocating memory for component %s\n", component.Name)
			-- for k, v in pairs(self.archetype.components[i]) do
			-- 	print(k, v)
			-- end
			for i = 1, component.size, 1 do
				dataOffset = dataOffset + 1
				local value = component.values[i]
				self.data[dataOffset] = value -- set each field to its default value
			end
		end
		self.numEntities = self.numEntities + 1
		self.entityIdToIndex[id] = self.numEntities
		self.entityIndexToId[self.numEntities] = id
		return self.numEntities
	else
		Feint.Log.logln("Archetype chunk is full")
	end
	return nil
end
function EntityChunk:preallocate(num)
	for j = 1, math.min(num, self.capacity), 1 do
		local dataOffset = j * self.entitySize
		for archetyeComponentIndex = 1, #self.archetype.components, 1 do
			local component = self.archetype.components[archetyeComponentIndex]
			-- Feint.Log.log("Allocating memory for component %s\n", component.Name)
			-- for k, v in pairs(self.archetype.components[i]) do
			-- 	print(k, v)
			-- end
			for i = 1, component.size, 1 do
				dataOffset = dataOffset + 1
				self.data[dataOffset] = component.values[i] -- set each field to its default value
			end
		end
		-- self.numEntities = self.numEntities + 1
		-- self.entityIdToIndex[id] = dataOffset / self.entitySize
		-- self.entityIndexToId[dataOffset / self.entitySize] = id
		-- return dataOffset / self.archetype.entitySize
		self.dataAlive = self.dataAlive + 1
		self.dataStatus[self.dataAlive] = true
	end
end
function EntityChunk:removeEntity(index)
	-- swap a removed entity with the last entity
	self.data[index], self.data[self.numEntities] = self.data[self.numEntities], self.data[index]
	self.numEntities = self.numEntities - 1
end
-- Feint.Util.Table.makeTableReadOnly(EntityChunk, function(self, k)
-- 	return string.format("attempt to modify %s", EntityChunk.Name)
-- end)
return EntityChunk
