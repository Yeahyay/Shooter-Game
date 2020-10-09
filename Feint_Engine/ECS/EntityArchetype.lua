local ECSutils = Feint.ECS.Util

local EntityArchetype = ECSutils.newClass("EntityArchetype")
function EntityArchetype:init(components, ...)
	-- holds components for the archetype
	self.components = components
	self.archetypeData = {}
	self.archetypeString = ""
	self.chunkCount = 0
	self.chunkCapacity = 32
	self:createArchetype()
end

function EntityArchetype:createArchetype()
	local components = self.components
	table.sort(components, function(a, b) return a.Name < b.Name end)
	for k, v in pairs(components) do
		print(k, v.Name)
	end
end

-- Feint.Util.Table.makeTableReadOnly(EntityArchetype, function(self, k)
-- 	return string.format("attempt to modify %s", EntityArchetype.Name)
-- end)
return EntityArchetype
