local graphics = {}

local private = {}

graphics.drawQueue = {}
graphics.drawQueueSize = 0
graphics.queueSize = 0
graphics.interpolateValue = 0
graphics.interpolateOn = true

local interpolate = 0

setmetatable(graphics, {
	__index = private,
	__newindex = private,
	-- __mode = "kv",
})

-- local rect = love.graphics.newMesh(
-- 	{{0, 0, 0, 0}, {1, 0, 0, 0}, {1, 1, 0, 0}, {0, 1, 0,0}},
-- 	"fan", "static")
-- local rectSX, rectSY = 1, 1

local rect = love.graphics.newImage("Assets/sprites/Test Texture 1.png")
local rectSX, rectSY = rect:getDimensions()

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

local screenSize
function private.init()
	screenSize = Feint.Graphics.ScreenSize
end
function private.rectangle(x, y, angle, width, height)
	graphics.drawQueueSize = graphics.drawQueueSize + 1
	local size = graphics.drawQueueSize
	local obj = graphics.drawQueue[size]
	if not obj then
		obj = {}
		graphics.drawQueue[size] = obj
		graphics.queueSize = graphics.queueSize + 1
	end
	obj[ENUM_INTERPOLATE_X] = x
	obj[ENUM_INTERPOLATE_Y] = Feint.Graphics.ScreenSize.y - y
	obj[ENUM_INTERPOLATE_A] = angle
	obj[ENUM_DRAW_CALL] = "rectangle"
	-- obj[ENUM_DRAW_MODE] = mode
	obj[ENUM_TRANSFORM_X] = x
	obj[ENUM_TRANSFORM_Y] = Feint.Graphics.ScreenSize.y - y
	obj[ENUM_TRANSFORM_A] = angle
	obj[ENUM_TRANSFORM_S_X] = width
	obj[ENUM_TRANSFORM_S_Y] = height
end

function private.rectangleInt(lx, ly, lr, x, y, angle, width, height)
	graphics.drawQueueSize = graphics.drawQueueSize + 1
	local size = graphics.drawQueueSize
	local obj = graphics.drawQueue[size]
	if not obj then
		obj = {}
		graphics.drawQueue[size] = obj
	end
	obj[ENUM_INTERPOLATE_X] = lx
	obj[ENUM_INTERPOLATE_Y] = screenSize.y - ly
	obj[ENUM_INTERPOLATE_A] = lr
	obj[ENUM_DRAW_CALL] = "rectangle"
	-- obj[ENUM_DRAW_MODE] = mode
	obj[ENUM_TRANSFORM_X] = x
	obj[ENUM_TRANSFORM_Y] = screenSize.y - y
	obj[ENUM_TRANSFORM_A] = angle
	obj[ENUM_TRANSFORM_S_X] = width
	obj[ENUM_TRANSFORM_S_Y] = height
end

function private.clear()
	graphics.drawQueueSize = 0
end

function private.draw()
	local loveGraphics = love.graphics
	for i = graphics.drawQueueSize, 1, -1 do
		local drawCall = graphics.drawQueue[i]
		local interX, interY = drawCall[ENUM_INTERPOLATE_X], drawCall[ENUM_INTERPOLATE_Y]
		local transformX, transformY = drawCall[ENUM_TRANSFORM_X], drawCall[ENUM_TRANSFORM_Y]

		local dx, dy = interX + interpolate * (transformX - interX), interY + interpolate * (transformY - interY)
		if drawCall[ENUM_DRAW_CALL] == "rectangle" then
			-- loveGraphics[drawCall[ENUM_DRAW_CALL]]("fill", dx, dy, drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y])
			-- print(transformX, interX, interpolate)
			loveGraphics.draw(rect, dx, dy, drawCall[ENUM_TRANSFORM_A],
				drawCall[ENUM_TRANSFORM_S_X], drawCall[ENUM_TRANSFORM_S_Y],
				rectSX / 2, rectSX / 2)
		end
	end
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

return graphics
