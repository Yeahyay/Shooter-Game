PriorityQueue = class("PriorityQueue")
function PriorityQueue:init(size)
	rawset(self, "Heap", Heap())
	rawset(self, "Size", self.Heap.Size)
end
function PriorityQueue:pairs(vals)
	local function iterator(t, i)
		i = i-1
		local v = t[i]
		if v ~= nil then
			return i, v.element
		else
			return nil
		end
	end
	return iterator, self.Heap.Nodes, self.Size+1 -- iterator, state, initial value
end
function PriorityQueue:getItems()
	return self.Heap.Nodes
end
function PriorityQueue:insert(item, priority)
	assert(item ~= nil, "Attempted to push a nil value.")
	self.Size = self.Size+1
	self.Heap:Insert(priority, item)
	self.Heap:Heapify()
end
-- function PriorityQueue:setItemPriority(item)
-- 	assert(item ~= nil, "Attempted to push a nil value.")
-- 	self.Size = self.Size+1
-- 	self.Heap:Insert(priority, item)
-- 	self.Heap:Heapify()
-- end
function PriorityQueue:pop()
	assert(self.Size > 0, "Priority Queue depth is negative. Too many pops.")
	self.Size = self.Size-1
	local item = self.Heap:GetNodeElement(1)
	self.Heap:Remove(1)
	self.Heap:Heapify()
	return item
end
function PriorityQueue:peek()
--	print("peeked "..self.Items[#self.Items])
	return self.Heap:GetNodeElement(1)
end
function PriorityQueue:empty()
	if self.Size == 0 then
--		print("empty")
		return true
	end
--	print("not empty")
	return false
end
function PriorityQueue:clear()
	self.Heap:Clear()
	self.Size = 0
	self.Heap:Heapify()
end
function PriorityQueue.__newindex(table, key, value)
	assert(table[key] ~= nil, "ATTEMPT TO MODIFY PRIORITY QUEUE BY ACCESSING KEY "..tostring(key))
end
