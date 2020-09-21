local function getTextDimensions(text, size)
	return fonts.current:getWidth(text)*size, fonts.current:getHeight()*size
end
local function printf(text, offX, offY, size, boundsX, boundsY)
	local width, height = getTextDimensions(text, size)
	if width > boundsX then
		size = size*boundsX/width
	end
	love.graphics.printf(text, offX-boundsX/2, offY+height/2, boundsX/size, "center", 0, size, -size)
end
local function depthFirst(index, target, targetType, currentNode, func, depth)
	depth = depth or 0
	width = width or 0
	index = index+1

	position = position or Vector2.new()
	currentNode.PositionOff = Vector2.new(-1, 0)
	local posOff = Vector2.new(0, 1)--mouse.Position/screenSize.y*25

	--[[if currentNode.Name == "Root" then --root is red
		love.graphics.setColor(1, 0, 0)
		currentNode.Position = posOff
	else]]
		love.graphics.setColor(1, 1, 1)
		currentNode.Position = Vector2.new(depth, 1-index)+posOff
		--currentNode.Position = Vector2.new(1, -currentNode.NodeNum)+currentNode.Parent.Position--mouse.Position/screenSize.y*20
	--end

	--if currentNode.Visible then --if the node is visible, then do the function
	func(currentNode, depth, index) --do given function to each node encountered
	--end

	depth = depth+1
	--if currentNode.Status == "Failure" then
	--	index = depthFirst(index, target, targetType, child, func, depth)
	--else
		local children = currentNode:getChildren()
		for childNum, child in pairs(children) do
			index = depthFirst(index, target, targetType, child, func, depth)
			if target == child or target == child.Name then
				break
			end
		end
	--end
	return index
end

BehaviorTree = class("BehaviorTree")
function BehaviorTree:init(name)
	self.Name = name
	self.Depth = 1
	--self.Nodes = {}
	--self.Nodes.root = {Name="root", parent=nil}
	self.Root = Node("Root", "Root", "Root", "Root")
	self.Position = Vector2.new()
	--self.Root.Parent = self.Root
	self.Processing = {}
	self.TraversalPath = {}
	self.Users = {}
	self.Parent = self
	self.SubTrees = {}
	self.Status = "Idle"
end
function BehaviorTree:update(recipient, ...)
	for _, child in pairs(self.Root.Children) do
		local childStatus = child:process(recipient, ...)
		self.Status = childStatus
		if childStatus == "Running" then
			--self.Status = "Running"
			break
		end
		if _ > 1 then
			error("Root node "..self.Name.." has more than one child!")
		end
	end
	return self.Status
	--[[self:depthFirst(self.Root, "", function(node, depth, index)

	end)]]
end
function BehaviorTree:addComposite(name, compositeSubType, parent)
	parent = parent or self.Root
	local newComposite = compositeSubType(name, "Composite", compositeSubType.Name, parent)--self:newNode(name, "Composite", compositeType, parent)
	newComposite.Parent:addChild(newComposite)
	return newComposite
end
function BehaviorTree:addLeaf(name, leafSubType, parent, variables, leafProcess)
	parent = parent or self.Root
	local newLeaf = leafSubType(name, "Leaf", leafSubType.Name, parent, variables, leafProcess)--self:newNode(name, "Composite", compositeType, parent)
	newLeaf.Parent:addChild(newLeaf)
	return newLeaf
end
function BehaviorTree:addSubTree(tree, parent)
	parent = parent or self.Root
	local newSubTree = SubTree(tree, parent)
	newSubTree.Parent:addChild(newSubTree)
	return newSubTree
end
function BehaviorTree:depthFirst(start, goal, ...) --wrapper for depth first
	local goalType = goal and (class.isClass(goal.class) and "node" or type(goal) == "string" and "name")
	local total = depthFirst(0, goal, goalType, start, ...)
end

function BehaviorTree:draw(name)
	local depth = 0
	local size = Vector2.new(400, 48)
	local spacing = Vector2.new(40, size.y*1.2)
	if true then
		love.graphics.push()

			--love.graphics.translate(screenSize.x/2, screenSize.y/2)
			--love.graphics.scale(1, -1)
			love.graphics.rectangle("line", -2, -2, 4, 4)

			self:depthFirst(self.Root, nil, function(node, depth, index)
				love.graphics.push()

					--local text = node.Name.."; Children: "..node.Degree.."; Depth: "..level..", "..index.."; Parent: "..tostring(node.Parent and node.Parent.Name or "Root")
					local text = node.Status.."; Name: "..node.Name..", "..node.Type..", "..node.SubType.."; Parent: "..
						tostring(node.Parent and node.Parent.Name or "Root")..", "..node.Level..", "..node.Depth
					local textWidth, textHeight = getTextDimensions(text, 0.2)
					local width = textWidth > size.x and textWidth or size.x
					local position = self.Position+node.Position%spacing-Vector2.new(size.x/2, 0)
					local parentPosition = self.Position+node.Parent.Position%spacing-Vector2.new(size.x/2, 0)

					if depth > 0 then
						if node.Status == "Success" then
							love.graphics.setColor(0, 1, 0)
						elseif node.Status == "Failure" then
								love.graphics.setColor(1, 0, 0)
						elseif node.Status == "Running" then
								love.graphics.setColor(0, 0, 1)
						end
						love.graphics.line(position.x, position.y, parentPosition.x+spacing.x/2, position.y, parentPosition.x+spacing.x/2, parentPosition.y-size.y/2)
					end
					love.graphics.translate(position:split())

					love.graphics.rectangle("line", 0, -size.y/2, width, size.y)
					printf(text, width/2, 0, 0.2, width, size.y)

				love.graphics.pop()
			end)

		love.graphics.pop()
	end
end
