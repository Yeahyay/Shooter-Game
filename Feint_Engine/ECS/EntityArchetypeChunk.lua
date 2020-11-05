local ECSutils = Feint.ECS.Util

local EntityChunk = ECSutils.newClass("EntityChunk")
function EntityChunk:init(archetype, ...)
	assert(Feint.Util.Core.type(archetype) == "table", 1, "EntityArchetypeChunk needs an archetype")
	self.archetype = archetype
	self.Name = archetype.Name.."_ArchetypeChunk"
	self.isFull_cached = false
	self.capacity = 128
	self.numEntities = 0
	self.data = {}
	self.entityIdToIndex = {}
	self.entityIndexToId = {}
	self.entitySize = 0 -- how many indices an entity takes up
	self.dataLayout = {}
	for i = 1, self.capacity do
		self.data[i] = nil -- presize the table's hash portion
	end

	self.dead = false

	self.archetype.chunkCount = self.archetype.chunkCount + 1
end
function EntityChunk:remove()
	self.archetype.chunkCount = self.archetype.chunkCount - 1
	for k, v in pairs(self) do
		self[k] = nil
	end
	self.dead = true
end
function EntityChunk:isFull()
	return self.numEntities >= self.capacity
end
function EntityChunk:isEMpty()
	return self.numEntities <= 0
end
-- function EntityChunk:getEntity()
function EntityChunk:newEntity(id)
	assert(type(id) == "number" and id >= 0, 3, "new entity expects a number")
	local dataOffset = self.numEntities * self.archetype.totalSize
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
	self.numEntities = self.numEntities + 1
	self.entityIdToIndex[id] = dataOffset / self.archetype.totalSize
	self.entityIndexToId[dataOffset / self.archetype.totalSize] = id
	return dataOffset / self.archetype.totalSize
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
