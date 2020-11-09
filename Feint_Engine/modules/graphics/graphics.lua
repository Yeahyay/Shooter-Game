local graphics = {}

local private = {}

graphics.drawQueue = {}
graphics.drawQueueSize = 0
graphics.interpolateValue = 0
graphics.interpolateOn = true

local interpolate = 0

setmetatable(graphics, {
	__index = private,
	__newindex = private,
	-- __mode = "kv",
})

local rect = love.graphics.newMesh{{0,0, 0,0}, {1,0, 0,0}, {1,1, 0,0}, {0,1, 0,0}}

function private.rectangle(lx, ly, lr, mode, x, y, angle, width, height)
	graphics.drawQueueSize = graphics.drawQueueSize + 1
	local size = graphics.drawQueueSize
	local obj = graphics.drawQueue[size]
	if not obj then
		graphics.drawQueue[size] = {
			"rectangle",
			lx,
			Feint.Graphics.G_SCREEN_SIZE.y - ly,
			lr,
			mode,
			x,
			Feint.Graphics.G_SCREEN_SIZE.y - y,
			width,
			height
		}
	else
		obj[1] = "rectangle"
		obj[2] = lx
		obj[3] = Feint.Graphics.G_SCREEN_SIZE.y - ly
		obj[4] = lr
		obj[5] = mode
		obj[6] = x
		obj[7] = Feint.Graphics.G_SCREEN_SIZE.y - y
		obj[8] = width
		obj[9] = height
	end
end

function private.clear()
	graphics.drawQueueSize = 0
end

function private.draw()
	local loveGraphics = love.graphics
	for i = graphics.drawQueueSize, 1, -1 do
		local drawCall = graphics.drawQueue[i]
		local px, py = drawCall[2], drawCall[3]
		local tx, ty = drawCall[6], drawCall[7]
		local dx, dy = px + interpolate * (tx - px), py + interpolate * (ty - py)
		loveGraphics[drawCall[1]](drawCall[5], dx, dy, select(8, unpack(drawCall)))
	end
end

function private.toggleInterpolation()
	graphics.interpolateOn = not graphics.interpolateOn
end

function private.updateInterpolate(value)
	if graphics.interpolateOn then
		interpolate = math.sqrt(value / Feint.Run.rate, 2)
	else
		interpolate = 0
	end
end

return graphics
