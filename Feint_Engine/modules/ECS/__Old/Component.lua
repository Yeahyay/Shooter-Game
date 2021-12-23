local ffi = require("ffi")

local Component = setmetatable({}, {})
Component.NIL = "NIL_MEMBER"
Component.ENTITY = "ENTITY_MEMBER"
Component.DEFINED_TYPES = {}

function Component:new(name, data, ...)
	name = name and name:gsub(" ", function(s)
		printf("COMPONENT NAME WARNING: converted space in %q to \"_\"\n", name)
		return ""
	end)
	if self:exists(name) then
		printf("COMPONENT DEFINITION WARNING: component %q is already defined\n", name)
		return self.DEFINED_TYPES[name]
	end

	local component = {
		ECSData = true;
		ECSType = "Component";
		NameDisplay = false;
		Name = name or "?";
		NameType = "Component_" .. (name or "?");
	}
	component.NameDisplay = string.format("Component %q (%s)", name or "?", tostring(component):gsub("table: ", ""))
	setmetatable(component, {
		__index = self;
		__tostring = function()
			return component.NameDisplay
		end;
	})
	component:init(data, ...)
	Component.DEFINED_TYPES[component.Name] = component
	Feint.Util.Table.makeTableReadOnly(component, function(self, k)
		return string.format("attempt to modify %s", component.NameDisplay)
	end)
	return component
end
function Component:exists(componentName)
	return Component.DEFINED_TYPES[componentName]
end
function Component:init(members, ...)
	assert(members ~= nil, "no members given")
	assert(type(members) == "table", methodExpects("Component", members, 1, "table"))--string.format("Component:init expected a %s, got a %s (%s) instead\n", "table", type(members), members))
	local empty = true
	if #members > 0 then
		empty = false
	elseif next(members, nil) then
		empty = false
	end
	assert(not empty, "no members declared")
	self.numMembers = 0
	self.sizeBytes = 0
	self.sizeBytesRaw = 0

	self.members = members
	self.initValues = {}
	self.strings = {}
	-- self.arrays = {}
	self.orderedMembers = {}
	self.ffiType = false
	local dataTypeLUT = {
		number = "float";
		table = "array";
		boolean = "bool";
	}
	local numberAttributes = {
		float = true;
		double = true;
		int = true;
		long = true;
	}
	getmetatable(self).__newindex = function(t, k, v)
		error(string.format("attempt to modify table %s with key %s value %s\n", t, k, v), 2)
	end
	local structMembers = {}
	for member, value in pairs(members) do
		self.orderedMembers[#self.orderedMembers + 1] = member
		local dataType = type(value)
		if dataType == "string" then

			-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof("cstring")
			structMembers[#structMembers + 1] = "cstring " .. member
			-- structMembers[#structMembers + 1] = "const char* " .. k

			self.initValues[member] = value

			self.strings[member] = value
			-- the data table is used for initialization
			-- setting it to nil because it is initialized manually
			-- self.members[k] = nil--ffi.C.malloc(k:len())
		elseif dataType == "table" then
			if value.ARRAY_TYPE then
				-- print("ARRAY")
				structMembers[#structMembers + 1] = value.type .. "* " .. member
				self.initValues[member] = value.data
			elseif value.LIST_TYPE then
				-- print("LIST")
				structMembers[#structMembers + 1] = value.type .. "* " .. member
				self.initValues[member] = value.data
			elseif value.LIST_MIXED_TYPE then
				-- print("LIST MIXED")
				structMembers[#structMembers + 1] = "void* " .. member
				self.initValues[member] = value.data
			elseif #value == 2 then -- number attribute
				local attribute = value[1]
				local number = value[2]
				assert(numberAttributes[attribute], "invalid number attribute " .. attribute)
				structMembers[#structMembers + 1] = attribute .. " " .. member
				self.initValues[member] = number

				-- print("NUMBER ATTRIBUTE")
			else
				print("WHAT")
				error("Raw tables are not allowed in components", 3)
			end
		else

			-- self.sizeBytesRaw = self.sizeBytesRaw + ffi.sizeof(dataType)
			structMembers[#structMembers + 1] = dataTypeLUT[dataType] .. " " .. member
			-- print(dataTypeLUT[dataType] .. " " .. member)
			-- print("saniodjoiuhiui90i-j9ioubipoji")
			self.initValues[member] = value
		end

		self.numMembers = self.numMembers + 1
	end
	-- self.members = structMembers

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
	]], self.NameType, #t > 0 and t .. ";" or "", padding)
	-- print(s)
	ffi.cdef(s)
	self.ffiType = ffi.metatype("struct ".. self.NameType, {
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
	self.sizeBytesRaw = ffi.sizeof("struct " .. self.NameType)
	self.sizeBytes = self.sizeBytesRaw + padding
end

function Component.ARRAY(arg1, arg2)
	if type(arg) == "table" then
		local array
		local elementType = "float"
		if type(arg1) == "string" then
			array = arg2
			elementType = arg1
		else
			array = arg1
		end
		local arrayData = {
			ARRAY_TYPE = true;
			data = {};
			type = elementType;
			size = #array;
		}
		local memberType = nil
		for k, v in ipairs(array) do
			if memberType == nil then
				memberType = type(v)
			else
				if type(v) ~= memberType then
					error("an array cannot have mixed types")
				end
			end
			arrayData.data[k] = v
		end
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

function Component.LIST(arg1, arg2)
	if type(arg) == "table" then
		local list
		local elementType = "float"
		if type(arg1) == "string" then
			list = arg2
			elementType = arg1
		else
			list = arg1
		end
		local listData = {
			LIST_TYPE = true;
			data = {};
			type = elementType;
			size = #list;
		}
		local memberType = nil
		for k, v in ipairs(list) do
			if memberType == nil then
				memberType = type(v)
			else
				if type(v) ~= memberType then
					error("a list cannot have mixed types")
				end
			end
			listData.data[k] = v
		end
		return listData
	elseif type(arg) == "number" then
		local listData = {
			LIST_TYPE = true;
			data = {};
			size = arg;
		}
		return listData
	end
end

function Component.LIST_MIXED(arg)
	if type(arg) == "table" then
		local list = arg
		local listData = {
			LIST_MIXED_TYPE = true;
			data = {};
			size = #list;
		}
		for k, v in ipairs(list) do
			listData.data[k] = v
		end
		return listData
	elseif type(arg) == "number" then
		local listData = {
			LIST_MIXED_TYPE = true;
			data = {};
			size = arg;
		}
		return listData
	end
end

function Component:getMembers()
	return self.members
end
function Component:getInitValues()
	return self.initValues
end
return Component