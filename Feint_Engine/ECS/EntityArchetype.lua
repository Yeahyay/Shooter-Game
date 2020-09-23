local ECSutils = Feint.ECS.Util

local EntityArchetype = ECSutils.newClass("EntityArchetype")
function EntityArchetype:init(components, ...)
	-- holds components for the archetype
	self.components = components
	self.chunkCount = 0
	self.chunkCapacity = 32
end

-- Feint.Util.Table.makeTableReadOnly(EntityArchetype, function(self, k)
-- 	return string.format("attempt to modify %s", EntityArchetype.Name)
-- end)
return EntityArchetype
