-- luacheck: ignore

IdSystem = System({Id, "Id"})
function IdSystem:init()
	self.Ids = {}--id, entity
	self.IdsReverse = {}
end
function IdSystem:entityAdded(entity)
	local id = entity:get(Id).uuid
	self.IdsReverse[#self.IdsReverse+1] = id
	self.Ids[id] = {entity=entity, index=#self.Ids}
end
function IdSystem:getEntityFromId(id)
	if self.Ids[id] then
		return self.Ids[id].entity
	end
	return nil
end
function IdSystem:entityRemoved(entity)
	local id = entity:get(Id).uuid
	self.IdsReverse[self.Ids[id].index] = nil
	self.Ids[id] = nil
end

idSystem = IdSystem()
GameInstance:addSystem(idSystem, "getEntityFromId", "getEntityFromId", true)
