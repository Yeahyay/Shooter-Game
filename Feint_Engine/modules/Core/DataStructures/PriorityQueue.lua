local PriorityQueue = {}

function PriorityQueue:new(name, ...)
	local object = setmetatable({
		super = self;
		Name = name;
	}, {
		__index = self
	})
	object:init(...)
	return object
end
function PriorityQueue:init()
	self.heapData = {}
	self.items = {}
	self.size = 0
end

function PriorityQueue:insert(item, priority)
	self:insertHeap(priority, item)
end
function PriorityQueue:remove()
	return self:extractHeap()
end

-- HEAP
function PriorityQueue:getLeftChildHeap(index)
	return index * 2
end
function PriorityQueue:getRightChildHeap(index)
	return index * 2 + 1
end
function PriorityQueue:getParentIndexHeap(index)
	return math.floor(index * 0.5)
end
function PriorityQueue:extractHeap()
	local item = self.items[1]--self.heapData[1]
	self.heapData[1] = self.heapData[self.size]
	self.items[1] = self.items[self.size]

	local current = 1
	for i = 1, math.ceil(math.log(self.size)), 1 do
		local leftChild, rightChild = self:getLeftChildHeap(current), self:getRightChildHeap(current)
		if (leftChild + rightChild) * 0.5 >= self.size + 1 then
			break
		end
		local leastChild
		if not rightChild or rightChild > self.size then
			leastChild = leftChild
		else
			leastChild = self.heapData[leftChild] < self.heapData[rightChild] and leftChild or rightChild
		end

		if self.heapData[current] <= self.heapData[leastChild] then
			break
		end
		self.heapData[leastChild], self.heapData[current] = self.heapData[current], self.heapData[leastChild]
		self.items[leastChild], self.items[current] = self.items[current], self.items[leastChild]

		current = leastChild
	end

	self.heapData[self.size] = nil
	self.size = self.size - 1
	return item
end
function PriorityQueue:insertHeap(priority, item)
	self.size = self.size + 1
	self.heapData[self.size] = priority
	self.items[self.size] = item

	local current = self.size
	local parent = self:getParentIndexHeap(current)
	-- print("----")
	-- print(current, parent)
	-- print("-", math.ceil(math.log(self.size)), self.size)
	for i = 1, math.ceil(math.log(self.size)), 1 do
		-- print(current, parent)
		if parent == 0 then
			break
		end
		if self.heapData[current] > self.heapData[parent] then
			break
		end
		self.heapData[parent], self.heapData[current] = self.heapData[current], self.heapData[parent]
		self.items[parent], self.items[current] = self.items[current], self.items[parent]
		current = parent
		parent = self:getParentIndexHeap(current)
	end
	-- print("----")
end

return PriorityQueue
