local ECSUtils = Feint.ECS.Util

local System = ECSUtils.newClass("System")
function System:init()
	self.World = Feint.ECS.World.DefaultWorld
	self.EntityManager = self.World.EntityManager
end
function System:update(dt)
end

Feint.Util.Table.makeTableReadOnly(System, function(self, k)
	return string.format("attempt to modify %s", System.Name)
end)

return System
