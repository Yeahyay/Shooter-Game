Heap = class("Heap")
function Heap:init()
	rawset(self, "Size", 0)
	rawset(self, "Empty", true)
	rawset(self, "Nodes", {})
	rawset(self, "Nodes_LUT", {})
end
function Heap.__newindex(table, key, value)
	assert(table[key] ~= nil, "ATTEMPT TO MODIFY HEAP BY ACCESSING KEY "..tostring(key))
end
function Heap:Draw()
	GameInstance:emit("registerDrawFunction", "heapDebug", self, 700, {"All"}, function(self)
		local xStep = 0
		local yStep = 2
		local x, y = 0, 0
		for i=1, self.Size do
			if i == yStep then
				xStep = -i
				yStep = i*2
				y = y+1
				x = xStep/2+0.5
			end
			love.graphics.rectangle("line", x*35, y*-35, 20, 20)
			love.graphics.print(tostring(self.Nodes[i].value)..": "..tostring(self.Nodes[i].element), x*35, y*-35+20, 0, 0.15, -0.15)
		--	local parent = self:GetParentNode(i)
		--	local pX, pY =
		--	love.graphics.line()
			x = x+1
		end
	end)
end
function Heap:Insert(value, element)
	self.Nodes[self.Size+1] = {value=value, element=element}
	self.Nodes_LUT[self.Nodes[#self.Nodes].element] = #self.Nodes
	self.Size = self.Size+1
	-- self:Heapify()
end
function Heap:SetNodeValue(index, value)
	self.Nodes[index].value = value
	-- self:Heapify()
end
function Heap:Heapify(table, index)
	self.Nodes = table or self.Nodes
	self.Size = #self.Nodes
	for i = math.floor(self.Size), 1, -1 do
		self:Heapify_(self.Nodes, self.Size, i)
	end
	return self.Nodes
end
function Heap:Heapify_(table, size, index)
	local largest = index--table[index]
	local leftIndex = 2*index
	local rightIndex = 2*index+1
	local leftValue, rightValue = self:GetNodeValue(leftIndex), self:GetNodeValue(rightIndex)

	if leftValue and leftIndex <= size and leftValue > self:GetNodeValue(largest) then
		largest = leftIndex
	end
	if rightValue and rightIndex <= size and rightValue > self:GetNodeValue(largest) then
		largest = rightIndex
	end
	if largest ~= index then
		local lut = self.Nodes_LUT
		lut[table[index].element], lut[table[largest].element] = lut[table[largest].element], lut[table[index].element]

		table[index], table[largest] = table[largest], table[index]
		self:Heapify_(table, size, largest)
	end
	return iter
end
function Heap:GetNodeValue(node)
	if self.Nodes[node] then
		return self.Nodes[node].value
	end
	return nil
end
function Heap:GetNodeElement(node)
	if self.Nodes[node] then
		return self.Nodes[node].element
	end
end
function Heap:Clear()
	self.Nodes = {}
	self.Nodes_LUT = {}
	self.Size = 0
	self:Heapify()
end
function Heap:Remove(index)
	self.Nodes_LUT[self.Nodes[index:GetNodeElement()]] = nil
	self.Nodes[index] = nil
	table.remove(self.Nodes, index)
	self.Size = self.Size-1
	-- self:Heapify()
end

-- function Heap:Swap(index1, index2)
-- 	self.Nodes[index1], self.Nodes[index2] = self.Nodes[index2], self.Nodes[index1]
-- end
-- function Heap:HeapifyNonRecursive(table)
-- 	local table = table
-- 	self.Nodes = table
-- 	self.Size = #table
-- 	local errorCounter = 1--self.Size
-- 	while errorCounter > 0 do
-- 		errorCounter = 0
-- 		for currentNode=math.floor(self.Size), 1, -1 do
-- 			local currentNodeValue = self.Nodes[currentNode]
-- 			-- print("Current Node Value: "..currentNodeValue.." Index: "..currentNode)
-- 			local parent = self:GetParentNode(currentNode)
-- 			-- print("", "Parent Value: "..tostring(self:GetNodeValue(parent)).." Index: "..tostring(parent))
-- 			-- print("", currentNodeValue, self:GetNodeValue(parent))
-- 			if self:SiftDown(currentNode) then
-- 				errorCounter = errorCounter+1
-- 			end
-- 		end
-- 	end
-- 	--end
-- 	return table
-- end

-- function Heap:GetChildNodes(node)
-- 	return 2*node, 2*node+1
-- end
-- function Heap:GetParentNode(node)
-- 	return math.floor(node/2)
-- end
-- function Heap:SiftDown(nodeIndex)
-- 	local nodeValue = self.Nodes[nodeIndex]
-- 	local leftChild, rightChild = self:GetChildNodes(nodeIndex)
-- 	local leftChildValue, rightChildValue = self:GetNodeValue(leftChild), self:GetNodeValue(rightChild)
-- 	--	print(nodeIndex, nodeValue)
-- 	--	print("", leftChildValue, rightChildValue)
-- 	-- print(leftChild, rightChild)
-- 	-- print(leftChildValue, rightChildValue)
-- 	if leftChildValue and rightChildValue then
-- 		local maxNodeIndex
-- 		local maxNodeValue
-- 		if leftChildValue > rightChildValue then
-- 			maxNodeIndex = leftChild
-- 			maxNodeValue = leftChildValue
-- 		elseif rightChildValue > leftChildValue then
-- 			maxNodeIndex = rightChild
-- 			maxNodeValue = rightChildValue
-- 		end
-- 		if maxNodeValue and maxNodeValue > nodeValue then
-- 			self.Nodes[maxNodeIndex], self.Nodes[nodeIndex] = nodeValue, maxNodeValue
-- 		--	print(unpack(self.Nodes))
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
