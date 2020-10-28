local ECSutils = Feint.ECS.Util

local EntityChunk = ECSutils.newClass("EntityChunk")
function EntityChunk:init(archetype, ...)
	assert(Feint.Util.Core.type(archetype) == "table", "EntityArchetypeChunk needs an archetype")
	self.archetype = archetype
	self.Name = archetype.Name.."_ArchetypeChunk"
	self.isFull = false
	self.capacity = 128
	self.numEntities = 0
	self.data = {}
	for i = 1, self.capacity do
		self.data[i] = nil
	end

	self.archetype.chunkCount = self.archetype.chunkCount + 1
end
function EntityChunk:remove()
	self.archetype.chunkCount = self.archetype.chunkCount - 1
end
function EntityChunk:isFull()
	return self.numEntities < self.capacity
end
function EntityChunk:newEntity(data)
	return 0
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
