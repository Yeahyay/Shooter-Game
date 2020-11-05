local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

-- local ffi = require("ffi")

function Component:init(data, ...)
	self.keys = {}
	self.values = {}
	self.size = #data

	for k, v in ipairs(data) do
		for k, v in pairs(v) do
			self.keys[#self.keys + 1] = k
			self.values[#self.values + 1] = v
		end
	end
	self[1] = self.size
end
function Component:setData(data)
end
-- [[
function Component:new(name, data, ...)
	local instance = {
		Name = name or "?",
		componentData = true,
	}
	setmetatable(instance, {
		__index = self,
	})
	-- for k, v in pairs(data) do
	-- 	Feint.Log.logln(k .. "\t" .. tostring(v))
	-- end
	self.init(instance, data, ...)
	getmetatable(instance).__newindex = function(t, k, v)
		error("No.")
	end
	return instance
end
--]]
-- function Component:new(init, ...)
-- 	self.instances = self.instances + 1
-- 	for k, v in pairs(init) do
-- 		self.data[k] = v
-- 	end
-- 	return instance
-- end
--[[
function Component:new(name, ...)
	-- printf("%s", self.instances)
	local instance = {
		new = function(self, data)
			if data then
				setmetatable(data, {__index = self, __tostring = function() return name end})
				data.Name = self.Name .. "_instance" .. self.instances or "?"
			end
			return data
		end,
		Name = name or "?",
		componentData = true,
	}
	assert(type(name) == "string", "Name is not a string\n")
	setmetatable(instance, {
		__tostring = function()
			return instance.Name
		end
	})
	self.init(instance, ...)
	return instance
end
-- ]]
Feint.Util.Table.makeTableReadOnly(Component, function(self, k)
	return string.format("attempt to modify %s", Component.Name)
end)
return Component
