local graphics = {}

local private = {}

function graphics:load()
	
self.addQueue = {}
self.addQueueSize = 0
self.removeQueue = {}
self.removeQueueSize = 0
self.drawQueue = {}
self.drawQueueSize = 0
self.queueSize = 0
self.interpolateValue = 0
self.interpolateOn = true

local interpolate = 0

setmetatable(graphics, {
	__index = private,
	__newindex = private,
	-- __mode = "kv",
})

-- local rect = love.graphics.newMesh(
-- 	{{0, 0, 0, 0}, {32, 0, 0, 0}, {32, 32, 0, 0}, {0, 32, 0,0}},
-- 	"fan", "static")
-- local rectSX, rectSY = 1, 1

local rect = love.graphics.newImage("Assets/sprites/Test Texture 1.png")
local rectSX, rectSY = rect:getWidth() / 2, rect:getHeight() / 2

local rectBatch = love.graphics.newSpriteBatch(rect, nil, "stream")

local ENUM_INITIALIZER
do
	local enum_initializer_state = 0
	function ENUM_INITIALIZER(new)
		enum_initializer_state = new and 1 or enum_initializer_state + 1
		return enum_initializer_state
	end
end

-- luacheck: push ignore
local ENUM_INTERPOLATE_X = ENUM_INITIALIZER(true)
local ENUM_INTERPOLATE_Y = ENUM_INITIALIZER()
local ENUM_INTERPOLATE_A = ENUM_INITIALIZER()
local ENUM_DRAW_CALL = ENUM_INITIALIZER()
local ENUM_DRAW_MODE = ENUM_INITIALIZER()
local ENUM_TRANSFORM_X = ENUM_INITIALIZER()
local ENUM_TRANSFORM_Y = ENUM_INITIALIZER()
local ENUM_TRANSFORM_A = ENUM_INITIALIZER()
local ENUM_TRANSFORM_S_X = ENUM_INITIALIZER()
local ENUM_TRANSFORM_S_Y = ENUM_INITIALIZER()
-- luacheck: pop ignore

local renderSize
function private.init()
	renderSize = Feint.Graphics.RenderSize
end
function private.rectangle(x, y, angle, width, height)
	graphics.addQueueSize = graphics.addQueueSize + 1
	local size = graphics.addQueueSize
	local obj = graphics.addQueue[size]
	if not obj then
		obj = {}
		graphics.addQueue[size] = obj
		graphics.queueSize = graphics.queueSize + 1
	end
	obj[ENUM_INTERPOLATE_X] = x
	obj[ENUM_INTERPOLATE_Y] = renderSize.y - y
	obj[ENUM_INTERPOLATE_A] = angle
	obj[ENUM_DRAW_CALL] = "rectangle"
	-- obj[ENUM_DRAW_MODE] = mode
	obj[ENUM_TRANSFORM_X] = x
	obj[ENUM_TRANSFORM_Y] = renderSize.y - y
	obj[ENUM_TRANSFORM_A] = angle
	obj[ENUM_TRANSFORM_S_X] = width
	obj[ENUM_TRANSFORM_S_Y] = height
end

function private.rectangleInt(lx, ly, lr, x, y, angle, width, height)
	graphics.addQueueSize = graphics.addQueueSize + 1
	local size = graphics.addQueueSize
	local obj = graphics.addQueue[size]
	if not obj then
		obj = {}
		graphics.addQueue[size] = obj
	end
	obj[ENUM_INTERPOLATE_X] = lx
	obj[ENUM_INTERPOLATE_Y] = renderSize.y - ly
	obj[ENUM_INTERPOLATE_A] = lr
	obj[ENUM_DRAW_CALL] = "rectangle"
	-- obj[ENUM_DRAW_MODE] = mode
	obj[ENUM_TRANSFORM_X] = x
	obj[ENUM_TRANSFORM_Y] = renderSize.y - y
	obj[ENUM_TRANSFORM_A] = angle
	obj[ENUM_TRANSFORM_S_X] = width
	obj[ENUM_TRANSFORM_S_Y] = height
end

function private.clear()
	-- graphics.drawQueueSize = 0
	-- rectBatch:clear()
end

function private.processAddQueue()
	local loveGraphics = love.graphics
	for i = 1, graphics.addQueueSize, 1 do
		local drawCall = graphics.addQueue[i]
		local interX, interY = drawCall[ENUM_INTERPOLATE_X], drawCall[ENUM_INTERPOLATE_Y]
		local transformX, transformY = drawCall[ENUM_TRANSFORM_X], drawCall[ENUM_TRANSFORM_Y]

		-- local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)
		local dx, dy = transformX, transformY

		-- loveGraphics.draw(rect, math.floor(dx), math.floor(dy), drawCall[ENUM_TRANSFORM_A],
		-- 	drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y],
		-- 	rectSX, rectSX)
		rectBatch:add(math.floor(dx), math.floor(dy), drawCall[ENUM_TRANSFORM_A],
			drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y],
			rectSX, rectSX)

		graphics.drawQueueSize = graphics.drawQueueSize + 1
		graphics.drawQueue[graphics.drawQueueSize] = graphics.addQueue[i]
		graphics.addQueue[i] = nil
	end
	graphics.addQueueSize = 0
end

function private.processQueue()
	local loveGraphics = love.graphics
	local time = Feint.Util.Core.getTime()
	local oscillate = Feint.Math.oscillateManualSigned
	for i = graphics.drawQueueSize, 1, -1 do
		local drawCall = graphics.drawQueue[i]
		local interX, interY = drawCall[ENUM_INTERPOLATE_X], drawCall[ENUM_INTERPOLATE_Y]
		local transformX, transformY = drawCall[ENUM_TRANSFORM_X], drawCall[ENUM_TRANSFORM_Y]

		-- local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)

		local dx, dy = transformX + oscillate(time, 50, 2, i), transformY + oscillate(time, 50, 2, (i * i) % (2 * math.pi))

		-- loveGraphics.draw(rect, math.floor(dx), math.floor(dy), drawCall[ENUM_TRANSFORM_A],
		-- 	drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y],
		-- 	rectSX, rectSX)
		rectBatch:set(i, math.floor(dx), math.floor(dy), drawCall[ENUM_TRANSFORM_A],
			drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y],
			rectSX, rectSX)
	end

end

function private.draw()
	love.graphics.draw(rectBatch, 0, 0, 0, 1, 1)
end

function private.getQueueSize()
	return graphics.drawQueueSize
end

function private.toggleInterpolation()
	graphics.interOn = not graphics.interOn
end

function private.updateInterpolate(value)
	if graphics.interOn then
		interpolate = math.sqrt(value / Feint.Run.rate, 2)
	else
		interpolate = 0
	end
end

end

return graphics
