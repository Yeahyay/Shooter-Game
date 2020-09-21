local ECSUtils = Feint.ECS.Util
local EntityManager = Feint.ECS.EntityManager

local World = ECSUtils.newClass("World")
function World:init()
	self.systems = {}
	self.systemsCount = 0
	self.updateOrder = {}
	self.EntityManager = EntityManager(self.Name.."EntityManager")
end
World.DefaultWorld = World("DefaultWorld")

function World:generateUpdateOrderList()
	local list = {}
	for i = 1, self.systemsCount do
		list[i] = i
	end
	self:setUpdateOrderList(list)
end

function World:setUpdateOrderList(list)
	self.updateOrder = list
end

function World:update()
	local list = self.updateOrder
	for i = 1, #list do
		self.systems[list[i]]:update()
	end
end

function World:registerSystem(system)
	self.systemsCount = self.systemsCount + 1
	self.systems[self.systemsCount] = system
end

function World:destroy()
end

Feint.Util.makeTableReadOnly(World, function(self, k)
	return string.format("attempt to modify %s", World.Name)
end)
return World
