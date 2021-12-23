local ffi = require("ffi")

local EntityManager = setmetatable({}, {})
function EntityManager:new(name, data, ...)
	local entityManager = {
		ECSData = true;
		ECSType = "EntityManager";
		NameDisplay = false;
		Name = name or "?";
		NameType = "EntityManager_" .. (name or "?");
	}
	entityManager.NameDisplay = string.format("EntityManager %q (%s)", name or "?", tostring(entityManager):gsub("table: ", ""))
	setmetatable(entityManager, {
		__index = self;
		__tostring = function()
			return entityManager.NameDisplay
		end;
	})
	entityManager:init(data, ...)
	Feint.Util.Table.makeTableReadOnly(entityManager, function(self, k)
		return string.format("attempt to modify %s", entityManager.NameDisplay)
	end)
	return entityManager
end
function EntityManager:init(members, ...)
end
return EntityManager
