local mouse = {}
mouse.Position = Vector2.new()
mouse.PositionOld = Vector2.new()
mouse.PositionRaw = Vector2.new()
mouse.PositionRawOld = Vector2.new()

mouse.PositionDelta = Vector2.new()
mouse.PositionDeltaOld = Vector2.new()
-- mouse.PositionDeltaRaw = Vector2.new()
-- mouse.PositionDeltaRawOld = Vector2.new()

mouse.PositionUnit = Vector2.new()
mouse.PositionUnitOld = Vector2.new()
-- mouse.PositionUnitRaw = Vector2.new()
-- mouse.PositionUnitRawOld = Vector2.new()

mouse.PositionWorld = Vector3.new()
mouse.PositionWorldOld = Vector3.new()
-- mouse.PositionWorldRaw = Vector2.new()
-- mouse.PositionWorldRawOld = Vector3.new()

mouse.PositionWorldDelta = Vector2.new()
mouse.PositionWorldDeltaOld = Vector2.new()

mouse.ClickPosition = Vector2.new()
mouse.ClickPositionWorld = Vector2.new()
mouse.ClickPositionDelta = Vector2.new()

mouse.ReleasePosition = Vector2.new()
mouse.ReleasePositionWorld = Vector2.new()

mouse.BaseSize = Vector2.new(4, 4)
mouse.Size = Vector2.new(mouse.BaseSize:split())
mouse.Selected = false
mouse.Hovering = {}--PriorityQueue()
mouse.Hovering_LUT = {}
mouse.Hover = false
mouse.Selecting = false

mouse.Sizes = {Vector2.new(mouse.BaseSize:split())}

function mouse:getHover(priority)
	return self.Hover
end
function mouse:init()
	GameInstance:emit("registerDrawFunction", "mouse", self, 900, {"All"}, function(self)
		local baseSize = self.BaseSize

		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("fill", self.PositionWorld.x - baseSize.x / 2, self.PositionWorld.z - baseSize.y / 2, baseSize.x, baseSize.y)

		love.graphics.setColor(0.5, 0.5, 0.5, 0.25)
		for _, object in pairs(self.Hovering) do
			local body = object:get(Body)
			local pos = body.Position
			local size = body.Size
			love.graphics.rectangle("fill", pos.x - size.x / 2, pos.z - size.y / 2, size.x, size.y)
		end

		love.graphics.setColor(1, 1, 1, 0.5)
		if mouse.Hover then
			local body = mouse.Hover:get(Body)
			local pos = body.Position
			local size = body.Size
			love.graphics.rectangle("fill", pos.x - size.x / 2, pos.z - size.y / 2, size.x, size.y)
		end

		local size = self.Size
		love.graphics.setColor(0.5, 0.6, 0.8, 0.5)
		love.graphics.rectangle("fill", self.PositionWorld.x - size.x / 2, self.PositionWorld.z - size.y / 2, size.x, size.y)
	end)
end
function mouse:updatePosition()
	-- every frame due to camera external movements such as the camera
	self.PositionWorldOld = self.PositionWorld
	self.PositionWorld = GameInstance:emit("getMousePositionWorld")
	self.PositionWorldDeltaOld = self.PositionWorldDelta
	self.PositionWorldDelta = self.PositionWorld - self.PositionWorldOld
end
function mouse:getHoverRegion(object)
	local mouseBaseSize = self.BaseSize
	local body = object:get(Body)
	local inBounds = false
	local bodySize = body.Size
	local mousePos

	do
		local pos = vMath:vec3ToVec2(body.Position)
		local clampBL = Vector2.new(pos.x - bodySize.x / 2, pos.y - bodySize.y / 2)
		local clampTR = Vector2.new(pos.x + bodySize.x / 2, pos.y + bodySize.y / 2)
		mousePos = vMath:vec3ToVec2(self.PositionWorld)
		:clamp(clampBL, clampTR)
	end

	local size = Vector2.new(
		math.abs(mousePos.x - body.Position.x),
	math.abs(mousePos.y - body.Position.z))

	local minSize = self.BaseSize
	local sizeX = math.clamp(bodySize.x - size.x * 2, minSize.x, bodySize.x)
	local sizeY = math.clamp(bodySize.z - size.y * 2, minSize.y, bodySize.z)

	return Vector2.new(sizeX, sizeY)
end
local colliders = {}
local collidersOld = {}
function mouse:update()
	local pos = vMath:vec3ToVec2(self.PositionWorld)
	local size = Vector2.new()
	if self.Hover then
		size = self:getHoverRegion(self.Hover)
	else
		size.x = math.clamp(math.abs(self.PositionWorld.x - self.PositionWorldOld.x), self.BaseSize.x, math.huge)
		size.y = math.clamp(math.abs(self.PositionWorld.z - self.PositionWorldOld.z), self.BaseSize.y, math.huge)
	end

	local pos = vMath:vec3ToVec2(self.PositionWorld)

	collidersOld = colliders
	colliders = GameWorld:queryRectangleArea(pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y)
	for k, collider in pairs(colliders) do
		local object = collider:getObject()
		local id = object:get(Id).uuid
		if not self.Hovering_LUT[id] then
			self.Hovering[#self.Hovering + 1] = object
			self.Hovering_LUT[id] = #self.Hovering
		end
	end

	if #colliders > 0 and not self.Hover then
		self.Hover = colliders[1]:getObject()
	end
	if #colliders < #collidersOld then
		local test1 = false
		for _, collider in pairs(colliders) do
			if self.Hover == collider:getObject() then
				goto finish
			end
		end
		-- the current hovered object is not being hovered anymore
		-- iterate through every previously hovered object and test if it is being hovered
		for _, object in pairs(self.Hovering) do
			if object ~= self.Hover then
				local body = object:get(Body)
				local pos = vMath:vec3ToVec2(self.PositionWorld)
				local size = self:getHoverRegion(object)
				local colliders = GameWorld:queryRectangleArea(pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y)
				if #colliders > 0 then
					for _, collider in pairs(colliders) do
						if object == collider:getObject() then
							self.Hovering = {}
							self.Hovering_LUT = {}
							self.Hover = object
							goto finish
						end
					end
				end
			end
		end
		-- self.Hovering = {}
		-- self.Hovering_LUT = {}
		self.Hover = false
		::finish::
	end
	self.Size = size
end
util.makeTableReadOnly(mouse, function(self, k, v)
	return string.format("attempt to modify mouse by accessing key %s", key)
end)
-- mouse.__newindex = function(table, key, value)
-- 	assert(table[key] ~= nil, "ATTEMPT TO MODIFY MOUSE BY ACCESSING KEY "..tostring(key))
-- end
setmetatable(mouse, mouse)
