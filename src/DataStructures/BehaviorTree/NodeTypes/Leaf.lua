Leaf = Node:extend("Leaf")
function Leaf:init(name, nodetype, nodesubtype, parent, variables, leafProcess)
	Leaf.super.init(self, name, nodetype, nodesubtype, parent)
	--print(name, nodetype.Name, nodesubtype and nodesubtype.Name or subType, parent.Name, variables, leafProcess)
	--print(name, nodetype, nodesubtype, parent, variables, leafProcess)
	self.Position = Vector2.new()
	self.PositionOff = Vector2.new()
	self.Visible = true
	self.Status = "Idle"
	self.VariablesInit = {}
	if type(variables) == "table" then
		for k, v in pairs(variables) do
			self.VariablesInit[k] = v
		end
		self.Variables = variables
	else
		self.Variables = {variables}
	end
	--self.Variables = {}
	--print(name, variables)
	self.ProcessFunc = leafProcess
	--print(self.ProcessFunc, self.Name, self.Type.Name, self.Variables)
end
function Leaf:setProcess(func)
	self.Process = func
end
function Leaf:initProcess()
end
function Leaf:process(recipient, ...)
	--self.Status = "Idle"
	--print(self.Name)
	self.Status = self.ProcessFunc(self.Variables, recipient, ...)
	if self.Status == "Success" then
		if self.Status ~= "Success" then
			self.Status = "Success"
			--self:endProcess()
		end
	 	--return "Success"
	elseif self.Status == nil then
		error(self.Name.." has returned nil. Must be failure, running, or success.")
	elseif self.Status == "Running" then
		self.Status = "Running"
		--return "Running"
	else
		if self.Status ~= "Failure" then
			self.Status = "Failure"
			--self:endProcess()
		end
		--return "Failure"
	end
	return self.Status
end
function Leaf:endProcess(recipient, ...)
	for k, v in pairs(self.VariablesInit) do
		self.Variables[k] = v
	end
	--print(self.Name, self.Status)
end
