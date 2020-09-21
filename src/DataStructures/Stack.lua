local Stack = class("Stack")
function Stack:init(size)
	rawset(self, "Items", {})
	rawset(self, "MaxSize", size or math.huge)
	rawset(self, "Size", 0)
end
function Stack.__newindex(table, key, value)
	assert(table[key] ~= nil, "ATTEMPT TO STACK QUEUE BY ACCESSING KEY "..tostring(key))
end
function Stack:push(item)
	assert(item ~= nil, "Attempted to push a nil value.")
	assert(self.Size < self.MaxSize, "Stack size of "..self.MaxSize.." reached")
	self.Size = self.Size + 1
	self.Items[self.Size] = item
	-- print("pushed "..tostring(item))
end
function Stack:pop()
	assert(self.Size > 0, "Stack depth is negative. Too many pops.")
	local item = self.Items[self.Size]
	table.remove(self.Items, self.Size)
	self.Size = self.Size - 1
	-- print("popped "..tostring(item))
	return item
end
function Stack:pairs(vals)
	local function iterator(t, i)
		i = i - 1
		local v = t[i]
		if v ~= nil then
			return i, v
		else
			return nil
		end
	end
	return iterator, self.Items, self.Size + 1 -- iterator, state, initial value
end
function Stack:peek()
	--	print("peeked "..self.Items[#self.Items])
	return self.Items[self.Size]
end
function Stack:empty()
	if self.Size == 0 then
		--		print("empty")
		return true
	end
	--	print("not empty")
	return false
end
function Stack:clear()
	self.Items = {}
	self.Size = 0
end
return Stack
