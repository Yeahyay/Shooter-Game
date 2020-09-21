Node = class("Node")
function Node:init(name, type, subtype, parent)
	self.Name = name or "unnamed"..subtype or error("No type specified")

	self.Type = type
		self.SubType = subtype or self.name

	self.Parent = (parent == "Root" and self) or assert(parent.Type ~= "Leaf", "A leaf cannot have a parent.") and parent or nil
		self.ChildIndex = 1
	self.Children = {} --directly connected to parent
		self.Degree = 0
	self.Descendents = {} --can be obtained by going down from parent
	self.Ancestors = {} --can be obtained by going up from child
	self.Depth = 0
	self.Level = 1

	self.Position = Vector2.new()
	self.PositionOff = Vector2.new()
	self.Visible = true
	self.Status = "Idle" --Success, Failure, Running, Idle
end
function Node:select()
	self.Selected = true
end
function Node:deselect()
	self.Selected = false
end
function Node:initProcess()
end
function Node:process(recipient, ...)
end
function Node:endProcess()
end
function Node:addChild(node)
	self.Children[#self.Children+1] = node
	self.Descendents[#self.Descendents+1] = node
	self.Degree = self.Degree+1
	node.NodeNum = self.Degree
	node.Depth = self.Depth+1
	node.Level = self.Level+1
end
function Node:getDescendents()

end
function Node:getChildren()
	return self.Children
end
function Node:hide()
	self.Visible = false
end
function Node:show()
	self.Visible = true
end
