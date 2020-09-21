local ECSutils = Feint.ECS.Util

local EntityChunk = ECSutils.newClass("EntityChunk")
function EntityChunk:init(archetype, ...)
	self.archetype = archetype or nil
	self.isFull = false
	self.capacity = 32
	self.numEntities = 0
	self.data = {}
end
function EntityChunk:newEntity(data)
	return 0
end
function EntityChunk:removeEntity()
end
-- Feint.Util.makeTableReadOnly(EntityChunk, function(self, k)
-- 	return string.format("attempt to modify %s", EntityChunk.Name)
-- end)
return EntityChunk
