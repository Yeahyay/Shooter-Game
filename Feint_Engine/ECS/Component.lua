local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

-- local ffi = require("ffi")

function Component:init(data, ...)
	self.instances = 0
	self.data = {}
	-- self.instantiate = self.new
	if data and #data > 0 then
		self:setData(data)
	end
	-- print("sldm"..tostring(self))
end
function Component:setData(data)
	for i = 1, #data do
		self.data[data[i]] = {}
	end
end
-- [[
function Component:new(name, data, ...)
	local instance = {
		-- data = {entityId = {}},
		new = function(self, data)

		end,
		Name = name or "?",
		componentData = true,
		init = false,
	}
	setmetatable(instance, {
		__index = self,
	})
	self.init(instance, data, ...)
	getmetatable(instance).__newindex = function(t, k, v)
		print(t, k, v)
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
	print(self, self.Super)
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
