Queue = class("Queue")
function Queue:init(size)
	self.Items = {}
	self.MaxSize = nil
	self.Size = 0
end
function Queue:push(item)
	assert(item ~= nil, "Attempted to push a nil value.")
	self.Size = self.Size+1
	table.insert(self.Items, 1, item)
	--self.Items[self.Size] = item
end
function Queue:pop()
	assert(self.Size > 0, "Queue depth is negative. Too many pops.")
	local item = self.Items[self.Size]
	table.remove(self.Items, self.Size)
	self.Size = self.Size-1
	return item
end
function Queue:peek()
--	print("peeked "..self.Items[#self.Items])
	return self.Items[1]
end
function Queue:empty()
	if self.Size == 0 then
--		print("empty")
		return true
	end
--	print("not empty")
	return false
end
function Queue:clear()
	self.Items = {}
	self.Size = 0
end
