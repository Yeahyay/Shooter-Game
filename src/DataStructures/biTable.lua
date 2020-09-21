local biTable = {}
biTable.Name = "Base BiTable"
biTable.string = tostring(biTable)

local function new()
	local newBiTable = {}
	newBiTable.Name = name or "?"
	newBiTable.Type = "BiTable"
	newBiTable.string = tostring(newBiTable)

	newBiTable.key = {}
	newBiTable.value = {}
	function newBiTable:set(k, v)
		self.key[k] = v
		self.value[v] = k
	end
	function newBiTable:setLUT(k, v, v2)
		self.key[k] = v
		self.value[v2] = k
	end
	function newBiTable:add(v)
		local size = self:size()
		self.key[size + 1] = v
		self.value[v] = size
	end
	function newBiTable:removeKey(k)
		self.value[self.key[k]] = nil
		self.key[k] = nil
	end
	function newBiTable:removeValue(v)
		self.key[self.value[value]] = nil
		self.value[v] = nil
	end
	function newBiTable:getKey(k)
		return self.key[k]
	end
	function newBiTable:getKeyFromValue(v)
		return self.key[self.value[v]] or false
	end
	function newBiTable:size()
		return #self.key
	end
	local mt = {
		__tostring = function()
			return string.format("BiTable %s (%s)", newBiTable.Name, newBiTable.string)
		end,
		__pairs = function(t, k, v)
			error("NO")
		end
	}
	setmetatable(newBiTable, mt)

	util.makeTableReadOnly(newBiTable, function(self, k)
		util.READ_ONLY_MODIFICATION_ERROR(self, k)
	end)
	return newBiTable
end
setmetatable(biTable, {
	__call = function(...) return new(...) end,
	__tostring = function()
		return string.format("%s (%s)", biTable.Name, biTable.string)
	end
})

util.makeTableReadOnly(biTable, function(self, k)
	util.READ_ONLY_MODIFICATION_ERROR(self, k)
end)
return biTable
