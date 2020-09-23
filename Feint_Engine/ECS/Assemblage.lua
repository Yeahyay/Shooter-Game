local ECSUtils = Feint.ECS.Util

local Assemblage = ECSUtils.newClass("Assemblage")
function Assemblage:init()
	-- holds components for the archetype
	self.components = {}
end

Feint.Util.Table.makeTableReadOnly(Assemblage, function(self, k)
	return string.format("attempt to modify %s", Assemblage.Name)
end)
return Assemblage
