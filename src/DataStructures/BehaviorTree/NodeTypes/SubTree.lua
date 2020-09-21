SubTree = Node:extend("SubTree")
function SubTree:init(tree, parent)
	SubTree.super.init(self, tree.Name, "SubTree", nil, parent)
	self.Tree = tree
end
function SubTree:process(recipient, ...)
	self.Status = self.Tree:update(recipient, ...)
	return self.Status
end
