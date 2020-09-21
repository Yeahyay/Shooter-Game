Selector = Composite:extend("Selector")
function Selector:init(name, type, subtype, parent)
	Selector.super.init(self, name, type, subtype, parent)
end
function Selector:process(recipient, ...)
	self.Status = "Running"
	for _, child in pairs(self.Children) do
		if self.Status == "Running" then
			if child.Status == "Idle" then
				child:initProcess()
			end

			child:process(recipient, ...)

			if child.Status == "Running" then
				self.Status = "Running"
				return "Running" --run this child first
			elseif child.Status == "Success" then
				self.Status = "Success"
			elseif child.Status == "Failure" then
				self.Status = "Running" --ignore failures
			end
		elseif self.Status == "Success" then --ignore others if success and return success
			child.Status = "Idle"
			child:endProcess()
		end
	end
	if self.Status ~= "Success" then
		self.Status = "Failure"
	end
	return self.Status
end
