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

function private.rectangle(lx, ly, lr, mode, x, y, width, height)
	graphics.drawQueueSize = graphics.drawQueueSize + 1
	graphics.drawQueue[graphics.drawQueueSize] = {"rectangle", lx, G_SCREEN_SIZE.y - ly, lr, mode, x, G_SCREEN_SIZE.y - y, width, height}
end

function private.clear()
	graphics.drawQueueSize = 0
end

function private.draw()
	for i = graphics.drawQueueSize, 1, -1 do
		local drawCall = graphics.drawQueue[i]
		local px, py = drawCall[2], drawCall[3]
		local tx, ty = drawCall[6], drawCall[7]
		local dx, dy = px + interpolate * (tx - px), py + interpolate * (ty - py)
		love.graphics[drawCall[1]](drawCall[5], dx, dy, select(8, unpack(drawCall)))
	end
end

function private.toggleInterpolation()
	graphics.interpolateOn = not graphics.interpolateOn
end

function private.updateInterpolate(value)
	if graphics.interpolateOn then
		interpolate = value / Feint.Run.rate
	else
		interpolate = 0
	end
	-- print(interpolate)
end

return graphics
