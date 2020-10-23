local ECSutils = Feint.ECS.Util

local EntityArchetype = ECSutils.newClass("EntityArchetype")

function EntityArchetype:init(components, ...)
	-- holds components for the archetype
	self.components = components
	self.archetypeData = {}
	self.archetypeString = nil
	self.chunkCount = 0
	self.chunkCapacity = 32
	self:createArchetype()
	return self
end

function EntityArchetype:createArchetype()
	local components = {}
	for i = 1, #self.components, 1 do
		local v = self.components[i]
		components[i] = v.Name
	end
	table.sort(components, function(a, b) return a < b end)
	self.archetypeString = table.concat(components)
	print(self.archetypeString)
end

-- Feint.Util.Table.makeTableReadOnly(EntityArchetype, function(self, k)
-- 	return string.format("attempt to modify %s", EntityArchetype.Name)
-- end)
return EntityArchetype
