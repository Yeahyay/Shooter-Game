local Stack = {}
function Stack:new(...)
	local object = {
		size = 0;
		items = {};
		push = function(self, item)
			self.size = self.size + 1
			self.items[self.size] = item
		end;
		pop = function(self)
			local item = self.items[self.size]
			self.size = self.size - 1
			return item
		end;
		reset = function(self)
			self.size = 0
		end;
	}
	return object
end
return Stack
