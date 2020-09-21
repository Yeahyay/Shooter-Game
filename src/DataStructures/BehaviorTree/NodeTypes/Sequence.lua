Sequence = Composite:extend("Sequence")
function Sequence:init(name, type, subtype, parent)
	Sequence.super.init(self, name, type, subtype, parent)
end
function Sequence:process(recipient, ...)
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
				self.Status = "Running" --continue if successful
			elseif child.Status == "Failure" then
				self.Status = "Failure" --ignore others if failure and return failure
			end
		elseif self.Status == "Failure" then
			child.Status = "Idle"
			child:endProcess()
		end
	end
	if self.Status ~= "Failure" then
		self.Status = "Success"
	end
	return self.Status
end
