local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")

Component.NIL = "NIL_MEMBER"
Component.ENTITY = "ENTITY_MEMBER"
function Component:init(members, ...)
	self.numMembers = #members
	self.sizeBytes = 0
	self.sizeBytesRaw = 0

	if Feint.ECS.FFI_OPTIMIZATIONS then
		-- self.members = members
		self.strings = {}
		self.orderedMembers = {}
		local structMembers = {}
		for k, v in pairs(members) do
			local dataType = type(v)
			self.orderedMembers[#self.orderedMembers + 1] = k
			if dataType == "string" then

				-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof("cstring")
				structMembers[#structMembers + 1] = "cstring " .. k
				-- structMembers[#structMembers + 1] = "const char* " .. k

				self.strings[k] = v
				-- the data table is used for initialization
				-- setting it to nil because it is initialized manually
				-- self.members[k] = nil--ffi.C.malloc(k:len())
			else
				dataType = dataType == "number" and "float" or dataType == "table" and "struct" or dataType == "boolean" and "bool"
				-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof(dataType)
				structMembers[#structMembers + 1] = dataType .. " " .. k
			end
		end

		-- table.sort(structMembers, function(a, b)
		-- 	return a < b
		-- end)
		-- for k, v in pairs(structMembers) do print(k, v) end

		local padding = 0--math.ceil(self.sizeBytesRaw / 64) * 64 - self.sizeBytesRaw
		-- self.sizeBytes = ffi.sizeof(self.ffiType)
		-- print(self.sizeBytesRaw, padding, self.sizeBytes)

		local t = table.concat(structMembers, ";\n")
		ffi.cdef(string.format([[
			#pragma pack(1)
			struct %s {
				%s
				char padding[%s];
			}
		]], self.ComponentName, #t > 0 and t .. ";" or "", padding))
		self.ffiType = ffi.metatype("struct ".. self.ComponentName, {
			__pairs = function(t)
				local function iter(t, k)
					k = k + 1
					if k <= #structMembers then
						return k, self.orderedMembers[k], t[self.orderedMembers[k]]
					end
				end
				return iter, t, 0
			end,
		})
		self.sizeBytesRaw = ffi.sizeof("struct " .. self.ComponentName)
		self.sizeBytes = self.sizeBytesRaw + padding
	else
		self.keys = {}
		self.values = {}
		self.sizeBytesRaw = 40 -- all tables are hash tables
		for k, v in ipairs(members) do
			for k, v in pairs(v) do
				self.keys[#self.keys + 1] = k
				self.values[#self.values + 1] = v
				if type(k) == "number" then
					self.sizeBytesRaw = self.sizeBytesRaw + 16 -- array
				else
					self.sizeBytesRaw = self.sizeBytesRaw + 40 -- hash table
				end
			end
		end
		local padding = math.ceil(self.sizeBytesRaw / 64) * 64 - self.sizeBytesRaw
		self.sizeBytes = self.sizeBytesRaw + padding
	end
end

function Component:new(name, data, ...)
	local instance = {
		Name = name or "?",
		ComponentName = "component_" .. (name or "?"),
		componentData = true,
	}
	setmetatable(instance, {
		__index = self,
	})
	instance:init(data, ...)
	getmetatable(instance).__newindex = function(t, k, v)
		error("No.")
	end
	return instance
end

Feint.Util.Table.makeTableReadOnly(Component, function(self, k)
	return string.format("attempt to modify %s", Component.Name)
end)
return Component
