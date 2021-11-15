local ECSUtils = Feint.ECS.Util
local Component = ECSUtils.newClass("Component")

local ffi = require("ffi")

Component.NIL = "NIL_MEMBER"
Component.ENTITY = "ENTITY_MEMBER"

function Component.ARRAY(arg)
	if type(arg) == "table" then
		local array = arg
		local arrayData = {
			ARRAY_TYPE = true;
			data = {};
			size = 0;
		}
		local memberType = nil
		for k, v in pairs(array) do
			if memberType == nil then
				memberType = type(v)
			else
				if type(v) ~= memberType then
					error("an array cannot have mixed types")
				end
			end
			arrayData.data[k] = v
		end
		arrayData.size = #array
		return arrayData
	elseif type(arg) == "number" then
		local arrayData = {
			ARRAY_TYPE = true;
			data = {};
			size = arg;
		}
		return arrayData
	end
end

function Component.LIST(list)
	if type(arg) == "table" then
		local list = arg
		local listData = {
			LIST_TYPE = true;
			data = {};
			size = 0;
		}
		local memberType = nil
		for k, v in pairs(list) do
			if memberType == nil then
				memberType = type(v)
			else
				if type(v) ~= memberType then
					error("a list cannot have mixed types")
				end
			end
			listData.data[k] = v
		end
		listData.size = #list
		return listData
	elseif type(arg) == "number" then
		local listData = {
			ARRAY_TYPE = true;
			data = {};
			size = arg;
		}
		return listData
	end
end

function Component.MAP(map)
	error("Go fuck yourself lmao")
	local mapData = {
		data = {};
		size = 0;
	}
	for k, v in pairs(map) do
		mapData.data[k] = v
	end
	mapData.size = #map
	return mapData
end

function Component:init(members, ...)
	self.numMembers = 0
	self.sizeBytes = 0
	self.sizeBytesRaw = 0

	self.members = members
	self.strings = {}
	self.arrays = {}
	self.orderedMembers = {}
	local dataTypeLUT = {
		number = "float";
		table = "array";
		boolean = "bool";
	}
	local structMembers = {}
	for member, value in pairs(members) do
		self.orderedMembers[#self.orderedMembers + 1] = member
		local dataType = type(value)
		if dataType == "string" then

			-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof("cstring")
			structMembers[#structMembers + 1] = "cstring " .. member
			-- structMembers[#structMembers + 1] = "const char* " .. k

			self.strings[member] = value
			-- the data table is used for initialization
			-- setting it to nil because it is initialized manually
			-- self.members[k] = nil--ffi.C.malloc(k:len())
		elseif dataType == "table" then
			if value.ARRAY_TYPE then
				print("ARRAY")
				print(member, value)
			elseif value.LIST_TYPE then
				print("LIST")
				print(member, value)
			else
				print("WHAT")
				error("Raw tables are not allowed in components", 3)
			end
		else

			-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof(dataType)
			structMembers[#structMembers + 1] = dataTypeLUT[dataType] .. " " .. member
		end

		self.numMembers = self.numMembers + 1
	end

	-- table.sort(structMembers, function(a, b)
	-- 	return a < b
	-- end)
	-- for k, v in pairs(structMembers) do print(k, v) end

	local padding = 0--math.ceil(self.sizeBytesRaw / 64) * 64 - self.sizeBytesRaw
	-- self.sizeBytes = ffi.sizeof(self.ffiType)
	-- print(self.sizeBytesRaw, padding, self.sizeBytes)

	local t = table.concat(structMembers, ";\n")
	local s = string.format([[
		// #pragma pack(1)
		struct %s {
			%s
			char padding[%s];
		}
	]], self.ComponentName, #t > 0 and t .. ";" or "", padding)
	print(s)
	ffi.cdef(s)
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
end

function Component:new(name, data, ...)
	name = name:gsub(" ", function(s)
		printf("COMPONENT NAME WARNING: converted space in %q to \"_\"\n", name)
		return ""
	end)
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
