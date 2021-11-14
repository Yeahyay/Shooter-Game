local Queue = {}
function Queue:new(...)
	local object = {
		size = 0;
		items = {};
		push = function(self, jobData)
			self.size = self.size + 1
			self.items[self.size] = jobData
		end;
		pop = function(self)
			local job = self.items[self.size]
			self.items[self.size] = nil
			self.size = self.size - 1
			return job
		end;
		empty = function(self)
			return self.size <= 0
		end
	}
	return object
end
return Queue
