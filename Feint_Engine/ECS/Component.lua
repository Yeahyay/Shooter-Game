local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")

function Component:init(data, ...)
	self.keys = {}
	self.values = {}
	self.size = #data

	if Feint.ECS.FFI_OPTIMIZATIONS then
		local structMembers = {}
		for k, v in ipairs(data) do
			for k, v in pairs(v) do
				local dataType = type(v)
				dataType = dataType == "number" and "float" or dataType == "table" and "struct" or dataType == "boolean" and "bool"
				self.keys[#self.keys + 1] = k
				self.values[#self.values + 1] = v

				structMembers[#structMembers + 1] = dataType .. " " .. k
			end
		end

		ffi.cdef(string.format([[
			#pragma pack(1)
			struct component_%s {
				%s
			}
		]], self.Name, table.concat(structMembers, ";\n") .. ";"))
		local ffiType = ffi.typeof("struct component_" .. self.Name)
		self.ffiType = ffi.metatype(ffiType, {
			__pairs = function(t)
				local function iter(t, k)
					k = k + 1
					if k <= #structMembers then
						return k, self.keys[k]
					end
				end
				return iter, t, 0
			end
		})

		self.sizeBytes = ffi.sizeof(self.ffiType)
		-- print(self.sizeBytes)
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

Feint.Util.Table.makeTableReadOnly(Component, function(self, k)
	return string.format("attempt to modify %s", Component.Name)
end)
return Component
