local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")

function Component:init(data, ...)
	self.size = #data
	self.sizeBytes = 0
	self.trueSizeBytes = 0

	if Feint.ECS.FFI_OPTIMIZATIONS then
		self.data = data
		self.strings = {}
		local structMembers = {}
		for k, v in pairs(data) do
			local dataType = type(v)
			if dataType == "string" then

				self.trueSizeBytes = self.trueSizeBytes + ffi.sizeof("cstring")
				structMembers[#structMembers + 1] = "cstring " .. k

				self.strings[k] = v
				-- the data table is used for initialization
				-- setting it to nil because it is initialized manually
				self.data[k] = nil--ffi.C.malloc(k:len())
				-- print(k, v, self.data[k])
			else
				dataType = dataType == "number" and "float" or dataType == "table" and "struct" or dataType == "boolean" and "bool"
				self.trueSizeBytes = self.trueSizeBytes + ffi.sizeof(dataType)
				structMembers[#structMembers + 1] = dataType .. " " .. k
			end
		end

		-- table.sort(structMembers, function(a, b)
		-- 	return a < b
		-- end)
		-- for k, v in pairs(structMembers) do print(k, v) end

		local padding = 0--math.ceil(self.trueSizeBytes / 64) * 64 - self.trueSizeBytes
		-- self.sizeBytes = ffi.sizeof(self.ffiType)
		self.sizeBytes = self.trueSizeBytes + padding
		-- print(self.trueSizeBytes, padding, self.sizeBytes)

		ffi.cdef(string.format([[
			#pragma pack(1)
			struct %s {
				%s
				char padding[%s];
			}
		]], self.ComponentName, table.concat(structMembers, ";\n") .. ";", padding))
		self.ffiType = ffi.metatype("struct ".. self.ComponentName, {
			__pairs = function(t)
				local function iter(t, k)
					k = k + 1
					if k <= #structMembers then
						return k, self.keys[k]
					end
				end
				return iter, t, 0
			end,
		})
		print(self.ffiType)

		-- print(self.sizeBytes)
	else
		self.keys = {}
		self.values = {}
		self.trueSizeBytes = 40 -- all tables are hash tables
		for k, v in ipairs(data) do
			for k, v in pairs(v) do
				self.keys[#self.keys + 1] = k
				self.values[#self.values + 1] = v
				if type(k) == "number" then
					self.trueSizeBytes = self.trueSizeBytes + 16 -- array
				else
					self.trueSizeBytes = self.trueSizeBytes + 40 -- hash table
				end
			end
		end
		-- self[1] = self.size
		local padding = math.ceil(self.trueSizeBytes / 64) * 64 - self.trueSizeBytes
		self.sizeBytes = self.trueSizeBytes + padding
		-- print(self.trueSizeBytes, padding, self.sizeBytes)
	end
end

-- function Component.modifyString()

function Component:new(name, data, ...)
	local instance = {
		Name = name or "?",
		ComponentName = "component_" .. (name or "?"),
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
