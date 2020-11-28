local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")

function Component:init(data, ...)
	self.keys = {}
	self.values = {}
	self.size = #data

	if jit.status() then
		self.structMembers = {}
		for k, v in ipairs(data) do
			for k, v in pairs(v) do
				local dataType = type(v)
				dataType = dataType == "number" and "double" or dataType == "table" and "struct" or dataType == "boolean" and "bool"
				self.keys[#self.keys + 1] = k
				self.values[#self.values + 1] = v

				self.structMembers[#self.structMembers + 1] = dataType .. " " .. k
			end
		end

		ffi.cdef(string.format([[
			#pragma pack(1)
			struct component_%s {
				%s
			}
			#pragma pack(0)
		]], self.Name, table.concat(self.structMembers, ";\n") .. ";"))
		self.ffiType = ffi.typeof("struct component_" .. self.Name)

		self.sizeBytes = ffi.sizeof(self.ffiType)
		print(self.sizeBytes)
	else
		self.sizeBytes = 40 -- all tables are hash tables
		for k, v in ipairs(data) do
			for k, v in pairs(v) do
				self.keys[#self.keys + 1] = k
				self.values[#self.values + 1] = v
				if type(k) == "number" then
					self.sizeBytes = self.sizeBytes + 16 -- array
				else
					self.sizeBytes = self.sizeBytes + 40 -- hash table
				end
			end
		end
		-- self[1] = self.size
	end
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
