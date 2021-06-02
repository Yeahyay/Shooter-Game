local batchSet = {}

function batchSet:new(...)
	local newBatch = {}
	setmetatable(newBatch, {
		__index = self
	})
	self.init(newBatch, ...)
	return newBatch
end
function batchSet:init(image)
	self.batches = {}
	self.batchSizes = {}
	self.batchCapacity = 1000
	self.invBatchCapacity = 1 / self.batchCapacity
	self.totalSize = 0
	self.image = image
	self.currentBatch = 0 -- currently free batch

	self:newBatch()
end
function batchSet:getBatches()
	return self.batches
end
local batch = {}
setmetatable(batch, {
	__index = {
		new = function(...)
			local newBatch = {
				size = 0, x = {}, y = {}, r = {}, w = {}, h = {}, ox = {}, oy = {}, visible = {}
			}
			setmetatable(newBatch, {
				__index = {
					add = function(self, x, y, r, w, h, ox, oy)
						self.size = self.size + 1
						local id = self.size
						self.x[id] = x
						self.y[id] = y
						self.r[id] = r
						self.w[id] = w
						self.h[id] = h
						self.ox[id] = ox
						self.oy[id] = oy
						self.visible[id] = false
					end;
					set = function(self, id, x, y, r, w, h)
						self.x[id] = x
						self.y[id] = y
						self.r[id] = r
						-- self.w[id] = w
						-- self.h[id] = h
					end;
					setVisible = function(self, id, visible)
						self.visible[id] = visible
					end
				}
			})
			return newBatch
		end
	}
})
function batchSet:newBatch()
	self.batches[#self.batches + 1] = batch:new()--love.graphics.newSpriteBatch(self.image, self.batchCapacity, "stream")
	self.batchSizes[#self.batchSizes + 1] = 0
	self.currentBatch = self.currentBatch + 1
end

-- function batchSet:setBatch(name)
-- 	assert(self.batches[name], "batch " .. name .. " does not exist")
-- 	self.currentBatch = self.batches[name]
-- end
function batchSet:addSprite(x, y, r, width, height, ox, oy)
	if self.batchSizes[self.currentBatch] >= self.batchCapacity then
		-- print(self.batchSizes[self.currentBatch], self.batchCapacity)
		self:newBatch()
	end

	self.batchSizes[self.currentBatch] = self.batchSizes[self.currentBatch] + 1
	self.batches[self.currentBatch]:add(x, y, r, width, height, ox, oy)
	self.totalSize = self.totalSize + 1
	return self.totalSize
end
function batchSet:updateSpriteData(id)
	local batch = self.batches[self.currentBatch]
	local size = self.batchSizes[self.currentBatch]
	batch[id], batch[size] = batch[size], nil
	size = size - 1
	self.batchSizes[self.currentBatch] = size
end
function batchSet:modifySprite(id, x, y, r, width, height)
	local spriteIndex = (id - 1) % self.batchCapacity + 1
	local batchIndex = math.ceil(id * self.invBatchCapacity)
	-- print(spriteIndex, batchIndex, #self.batches)
	self.batches[batchIndex]:set(spriteIndex, x, y, r, width, height)
end
function batchSet:setVisible(id, visible)
	local spriteIndex = (id - 1) % self.batchCapacity + 1
	local batchIndex = math.ceil(id * self.invBatchCapacity)
	-- print(spriteIndex, batchIndex, #self.batches)
	self.batches[batchIndex]:setVisible(spriteIndex, visible)
end
function batchSet:draw()
	for i = 1, #self.batches, 1 do
		local batch = self.batches[i]
		local x = batch.x
		local y = batch.y
		local r = batch.r
		local w = batch.w
		local h = batch.h
		local ox = batch.ox
		local oy = batch.oy
		local image = self.image
		for j = 1, self.batchSizes[i], 1 do
			if not batch.visible[j] then goto continue end
			-- local spriteIndex = (j - 1) % self.batchCapacity + 1
			-- love.graphics.rectangle("fill", batch.x[j], batch.y[j], 32 * batch.w[j], 32 * batch.h[j])
			love.graphics.draw(image, x[j], y[j], r[j], w[j], h[j], ox[j], oy[j])
			::continue::
		end
	end
end
-- function batchSet:addSprite(x, y, r, width, height)
-- 	local id = self.currentBatch:add(x, y, r, width, height)
-- 	-- self.images[id] = {x = x, y = y, r = r, width = width, height = height}
-- 	return id
-- end

return batchSet
