local mappedArray = {}
mappedArray.Name = "Base MappedArray"
mappedArray.string = tostring(mappedArray)

function mappedArray:add(v, LUTVal)
	local i = #self.values + 1
	self.values[i] = v
	self.values_LUT[LUTVal] = i
	self.size = self.size + 1
end
function mappedArray:addAtIndex(v, LUTVal, index)
	self.values[index] = v
	self.values_LUT[v] = index
	self.size = self.size + 1
end
function mappedArray:removeKey(k)
	self.values_LUT[self.values[k]] = nil
	self.values[k] = nil
	self.size = self.size - 1
end
function mappedArray:removeValue(v)
	self.values[self.values_LUT[values_LUT]] = nil
	self.values_LUT[v] = nil
	self.size = self.size - 1
end
function mappedArray:get(i)
	assert(type(i) == "number", util.BAD_ARG_ERROR(1, "mappedArray:get", "number", type(i)))
	return self.values[i]
end
function mappedArray:getLUTIndex(LUTval)
	return self.values_LUT[LUTVal] or false
end
function mappedArray:getLUT(LUTVal)
	return self.values[self.values_LUT[LUTVal]] or false
end

local function new(weakness)
	local newMappedArray = {}
	newMappedArray.Name = name or "?"
	newMappedArray.Type = "MappedArray"
	newMappedArray.string = tostring(newMappedArray)

	newMappedArray.values = {}
	newMappedArray.values_LUT = {}
	newMappedArray.size = 0
	local mt = {
		__index = mappedArray;
		__tostring = function()
			return string.format("MappedArray %s (%s)", newMappedArray.Name, newMappedArray.string)
		end;
		__mode = weakness;
	}
	setmetatable(newMappedArray, mt)

	util.makeTableReadOnly(newMappedArray, function(self, k)
		util.READ_ONLY_MODIFICATION_ERROR(self, k)
	end)
	return newMappedArray
end
setmetatable(mappedArray, {
	__call = function(...) return new(...) end,
	__tostring = function()
		return string.format("%s (%s)", mappedArray.Name, mappedArray.string)
	end
})

util.makeTableReadOnly(mappedArray, function(self, k)
	util.READ_ONLY_MODIFICATION_ERROR(self, k)
end)
return mappedArray
