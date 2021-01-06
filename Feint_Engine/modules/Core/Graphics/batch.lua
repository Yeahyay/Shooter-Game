local batch = {}

function batch:new()
	local newBatch = {}
	setmetatable(newBatch, {
		__index = self
	})
	return newBatch
end
function batch:init()
	self.batches = {}
	self.sprites = {}
	self.currentBatch = false
end
function batch:addBatch(name, batch)
	self.batches[name] = batch
end
function batch:setBatch(name)
	assert(self.batches[name], "batch " .. name .. " does not exist")
	self.currentBatch = self.batches[name]
end
function batch:modify(id, x, y, r, width, height)

end
function batch:addSprite(x, y, r, width, height)
	local id = self.currentBatch:add(x, y, r, width, height)
	self.sprites[id] = {x = x, y = y, r = r, width = width, height = height}
	return id
end

return batch
