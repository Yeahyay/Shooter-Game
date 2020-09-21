local enum = class("Enum")
enum.Name = "Base Enum"
enum.string = tostring(enum)

function enum:init(name)
	-- rawset(self, Name, name)
	rawset(self, "Name", name)
	rawset(self, "Value_LUT", {})
end
function enum:newItem(index, value)
	assert(not self[index], "attempt to assign value "..tostring(value).." to index "..index..". already has value")
	--print(index, value)
	rawset(self, index, {})
	self[index].Value = value
	self[index].Index = index
	self[index].Name = self.Name
	self[index].Enum = self
	-- self.ValueLU
	self.Value_LUT[value] = index
	--print(self.Items.index)
end
function enum:valueIsMember(value)
	return self.Value_LUT[value] and true or false
end
function enum:indexFromValue(value)
	return self.Value_LUT[value]
end
local function eq(a, b)
	--print(a, b, "pass")
	return true
end
enum.__newindex = function(table, key)
	-- if key ~= "Name" and key ~= "enumType" then
	assert(table[key], "attempt to access invalid member "..tostring(key).." in enum "..table.name)
	-- end
end
enum.__eq = eq
function enum.__tostring(a)
	return a.Name
end

return enum
