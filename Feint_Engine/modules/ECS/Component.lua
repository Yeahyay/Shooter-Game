local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")
ffi.cdef([[
	void* malloc(size_t size);
	int free(void* ptr);
	void* realloc(void* ptr, size_t size);
	size_t strlen(char* restrict str);
	void* calloc(size_t, size_t);
]])

local typeSize = {
	bool = ffi.sizeof("bool"),
	int8_t = ffi.sizeof("int8_t"),
	int16_t = ffi.sizeof("int16_t"),
	int32_t = ffi.sizeof("int32_t"),
	float = ffi.sizeof("float"),
	double = ffi.sizeof("double")
}
function Component:init(data, ...)
	self.size = #data
	self.sizeBytes = 0
	self.trueSizeBytes = 0

	if Feint.ECS.FFI_OPTIMIZATIONS then
		self.data = data
		self.strings = {}
		local structMembers = {}
		for k, v in pairs(data) do
			-- for k, v in pairs(v) do
			local dataType = type(v)
			if dataType == "string" then
				-- dataType = "char"
				-- local arraySize = v:len()
				-- print(v:len())

				self.trueSizeBytes = self.trueSizeBytes ffi.sizeof("uint8_t*")--+ arraySize
				-- structMembers[#structMembers + 1] = dataType .. " " .. k .. "[" .. arraySize .. "]"
				structMembers[#structMembers + 1] = "uint8_t* " .. k --.. "[" .. arraySize .. "]"
				structMembers[#structMembers + 1] = "uint8_t" .. " " .. k .. "Length"
				self.strings[k] = v
				self.data[k] = nil--ffi.C.malloc(k:len())
				-- print(k, v, self.data[k])
			else
				dataType = dataType == "number" and "float" or dataType == "table" and "struct" or dataType == "boolean" and "bool"
				self.trueSizeBytes = self.trueSizeBytes + typeSize[dataType]
				structMembers[#structMembers + 1] = dataType .. " " .. k
			end
			-- 	self.keys[#self.keys + 1] = k
			-- 	self.values[#self.values + 1] = v
			--
			--
			-- end
			-- print(k, v)
		end

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
		print(self.trueSizeBytes, padding, self.sizeBytes)
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
