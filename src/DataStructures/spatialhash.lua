SpatialHash = class("SpatialHash")
function SpatialHash:init(name)
	self.Name = name
	self.Buckets = {}
	self.BucketsReverse = {}
	self.ObjectsInHashArea = {Size = 0}
	self.Size = size or 100
	self.CellSize = cellSize or 128
	self.OriginOffset = Vector2.new(-self.Size / 2 * self.CellSize - self.CellSize / 2, - self.Size / 2 * self.CellSize - self.CellSize / 2) --offset from 0
	self.Offset = -Vector2.new(self.CellSize / 2, self.CellSize / 2)
	self.TopLeft = self.Offset + Vector2.new(-self.Size / 2 * self.CellSize, self.Size / 2 * self.CellSize)
	self.BottomRight = self.Offset + Vector2.new(self.Size / 2 * self.CellSize, - self.Size / 2 * self.CellSize)
	self:Populate()
	-- self:draw()
end
function SpatialHash:Populate()
	self.Buckets = {}
	for i = 1, self.Size * self.Size do
		self.Buckets[i] = SpatialHashCell(self:indexToCellPos(i), self.CellSize)
	end
end
SpatialHashCell = class("SpatialHashCell")
function SpatialHashCell:init(center, size)
	local size = Vector2.new(size, - size)
	self.TopLeft = center + size / 2
	self.BottomRight = center + size / 2
	self.Center = center
	self.Objects = {}
	self.Size = 0
end
function SpatialHashCell:AddObject(object)
	if not self.Objects[object.id] then
		self.Objects[object.id] = self.Size
		self.Size = self.Size + 1
	end
end
function SpatialHashCell:RemoveObject(object)
	if self.Objects[object.id] then
		self.Objects[object.id] = nil
		self.Size = self.Size - 1
	end
end
function SpatialHashCell:Reset()
	--	for k, v in pairs(self.Objects) do
	--		self.Objects[k] = nil
	--	end
	self.Objects = {}
	self.Size = 0
end
--[[function SpatialHashCell:TestObject(object)
	local object = self.Objects[object]
	local position = object.Position
	if position.x > self.TopLeft.x and position.x < self.BottomRight.x and
		position.y < self.TopLeft.y and position.y > self.BottomRight.y then

	end
end]]
function SpatialHash:draw()
	GameInstance:emit("registerDrawFunction", "SpatialHash", self, 700, {"Edit", "Debug"}, function()
		if false then
		love.graphics.setColor(1, 1, 1)
		love.graphics.push()
		love.graphics.translate((self.OriginOffset - self.Offset):split())
		love.graphics.setLineWidth(1)
		for y = 0, self.Size - 1 do
			--	love.graphics.translate(0, self.CellSize)
			for x = 0, self.Size - 1 do
				love.graphics.push()
				local index = self:cellPosToIndex(x, y)

				love.graphics.translate(x * self.CellSize, y * self.CellSize)
				--	local mode = "line"
				local size = self.Buckets[index].Size
				if size > 0 then
					love.graphics.setColor(1, 1, 1, size / 5)
					love.graphics.rectangle("fill", - self.CellSize / 2, - self.CellSize / 2, self.CellSize, self.CellSize)
				end
				--]]
				--	love.graphics.setColor(1, 1, 1, 1)
				--	love.graphics.rectangle("line", -self.CellSize/2, -self.CellSize/2, self.CellSize, self.CellSize)
				--	love.graphics.print(self:cellPosToIndex(x, y), -9, 0, 0, 0.125, -0.125)
				--	love.graphics.print(size, -9, 0, 0, 0.125, -0.125)
				--	local pos = self:indexToCellPos(self:cellPosToIndex(x, y))
				--	love.graphics.print(pos.x, -9, 14, 0, 0.125, -0.125)
				--	love.graphics.print(pos.y, -9, 2, 0, 0.125, -0.125)
				love.graphics.pop()
			end
		end
		love.graphics.pop()
		love.graphics.circle("fill", self.TopLeft.x, self.TopLeft.y, self.CellSize / 4)
		love.graphics.circle("fill", self.BottomRight.x, self.BottomRight.y, self.CellSize / 4)
	end
end)
end
function SpatialHash:cellPosToIndex(x, y)
return (y * self.Size) + x + 1
end
function SpatialHash:indexToCellPos(index)
return Vector2.new(((index - 1)%self.Size) * self.Size, (math.ceil(index / self.Size) - 1) * self.Size)
end
function SpatialHash:cellPosToWorld(x, y)
return Vector2.new(x, y) * self.CellSize
end
function SpatialHash:WorldToCellPos(position)
local tl, br = Vector2.new(self.TopLeft.x, self.BottomRight.y), Vector2.new(self.TopLeft.y, self.BottomRight.x)
return ((vMath:vec3ToVec2(position):clamp(tl, br) - self.OriginOffset) / self.CellSize).floor
end
memoize(SpatialHash.cellPosToIndex)
memoize(SpatialHash.cellPosToWorld)
memoize(SpatialHash.indexToCellPos)
function SpatialHash:WorldToCellIndex(position)

return self:cellPosToIndex(self:WorldToCellPos(position):split())
end
function SpatialHash:ObjectInArea(object)
if self.ObjectsInHashArea then
	return true
end
return false
end
function SpatialHash:AddObject(object, position, id)
if not self.ObjectsInHashArea[id] then
	self.ObjectsInHashArea[id] = {object = object, Position = position, id = id, Bucket = nil}
	self.ObjectsInHashArea.Size = self.ObjectsInHashArea.Size + 1
end
end
function SpatialHash:RemoveObject(id)
if self.ObjectsInHashArea[id] then
	local object = self.ObjectsInHashArea[id]
	self.Buckets[object.Bucket]:RemoveObject(object)
	self.ObjectsInHashArea[id] = nil
	self.ObjectsInHashArea.Size = self.ObjectsInHashArea.Size - 1
end
end
function SpatialHash:AddObjectToBucket(object, bucket)
if object.Bucket then
	self.Buckets[object.Bucket]:RemoveObject(object)
end
if bucket <= self.Size * self.Size then -- if bucket is in bounds
	object.Bucket = bucket
	self.Buckets[bucket]:AddObject(object)
end
end
function SpatialHash:UpdateObject(object)
--	print(object.object)
if object.object[Body].Dead then
	self:RemoveObject(object.id)
else
	local pos = object.object[Body] and object.object[Body].Position or object.object.PositionWorld-- or Vector3.new()
	if pos then
		object.Position = pos
		--	print(object.Position)
		local index = self:WorldToCellIndex(object.Position)
		--	print(index)
		self:AddObjectToBucket(object, index)
	end
end
end
function SpatialHash:Update()
if true then--self.ObjectsInHashArea.Size > 0 then
	for _, object in pairs(self.ObjectsInHashArea) do
		if type(object) ~= "number" then
			self:UpdateObject(object)
		end
	end
end
--	print(self.ObjectsInHashArea.Size)
end
function SpatialHash:Clear()
self.ObjectsInHashArea = {Size = 0}
for k, v in pairs(self.Buckets) do
	v:Reset()
end
collectgarbage()
collectgarbage()
end
function SpatialHash:Reset()
self:Clear()
--	self:Populate()
end
function SpatialHash:TestObject(object)
local position
local id
if object.has and object:has(Id) and object ~= mouse then
	if object:has(Body) then
		local body = object:get(Body)
		position = body.Position
		id = object:get(Id).uuid
	end
elseif object == mouse then
	position = object.PositionWorld
	id = object.id
end
--	print(object, position)
if position and object:has(Body) or object == mouse then
	if position.x > self.TopLeft.x and position.x < self.BottomRight.x and
	position.y < self.TopLeft.y and position.y > self.BottomRight.y then
		local index = self:WorldToCellIndex(position)
		self:AddObject(object, position, id)
		--	print(position, object)
		--	print(index)
		--	self.Buckets[index]:AddObject(object, id)
	else
		self:RemoveObject(id)
	end
end
end
