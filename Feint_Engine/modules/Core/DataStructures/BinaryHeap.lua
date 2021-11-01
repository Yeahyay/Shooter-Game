local BinaryHeap = {}

function BinaryHeap:new(name, ...)
	local object = setmetatable({
		super = self;
		Name = name;
	}, {
		__index = self
	})
	object:init(...)
	return object
end
function BinaryHeap:init()
	self.data = {}
	self.size = 0
end
function BinaryHeap:getLeftChild(index)
	return index * 2
end
function BinaryHeap:getRightChild(index)
	return index * 2 + 1
end
function BinaryHeap:getParentIndex(index)
	return math.floor(index * 0.5)
end
function BinaryHeap:extract()
	local item = self.data[1]
	self.data[1] = self.data[self.size]

	local current = 1
	for i = 1, math.ceil(math.log(self.size)), 1 do
		local leftChild, rightChild = self:getLeftChild(current), self:getRightChild(current)
		if (leftChild + rightChild) * 0.5 >= self.size + 1 then
			break
		end
		local leastChild
		if not rightChild or rightChild > self.size then
			leastChild = leftChild
		else
			leastChild = self.data[leftChild] < self.data[rightChild] and leftChild or rightChild
		end

		if self.data[current] <= self.data[leastChild] then
			break
		end
		self.data[leastChild], self.data[current] = self.data[current], self.data[leastChild]

		current = leastChild
	end

	self.data[self.size] = nil
	self.size = self.size - 1
	return item
end
function BinaryHeap:insert(item)
	self.size = self.size + 1
	self.data[self.size] = item

	local current = self.size
	local parent = self:getParentIndex(current)
	for i = 1, math.ceil(math.log(self.size)), 1 do
		if self.data[current] > self.data[parent] then
			break
		end
		self.data[parent], self.data[current] = self.data[current], self.data[parent]
		current = parent
		parent = self:getParentIndex(current)
	end
end

return BinaryHeap
