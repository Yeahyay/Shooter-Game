local tempModuleObject = {}

local function mergeTables(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			mergeTables(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

function tempModuleObject:new(...)
	local newTempModule = {}
	local s = tostring(newTempModule)
	setmetatable(newTempModule, {
		__index = self,
		__tostring = function()
			return "Temp Module: " .. s:gsub("table: ", "")
		end
	})
	newTempModule:init(...)
	return newTempModule
end
function tempModuleObject:init(name)
	self.Name = name
end
function tempModuleObject:convert(table2)
	self.Name = nil
	self.convert = nil
	self = mergeTables(table2, self)
	setmetatable(self, getmetatable(table2))
end

return tempModuleObject
