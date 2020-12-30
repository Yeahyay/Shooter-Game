local tickModule = {
	framerate = -1,
	rate = .03,
	timescale = 1,
	sleep = .001,
	dt = 0,
	accum = 0,
	tick = 1,
	frame = 1,
	paused = false,
}

local timer = love.timer
local graphics = love.graphics

love.run = function()
	if not timer then
		error('love.timer is required for tick')
	end

	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end
	timer.step()
	local lastframe = 0

	love.update(0)

	while true do
		timer.step()
		tickModule.dt = timer.getDelta() * tickModule.timescale
		if not tickModule.paused then
			tickModule.accum = tickModule.accum + tickModule.dt
		else
			-- tickModule.accum = tickModule.rate
		end

		local isDraw = graphics and graphics.isActive()

		if isDraw then
			graphics.clear(graphics.getBackgroundColor())
			graphics.origin()
		end

		if not tickModule.paused then
			while tickModule.accum >= tickModule.rate do
				tickModule.accum = tickModule.accum - tickModule.rate

				if love.event then
					love.event.pump()
					for name, a, b, c, d, e, f in love.event.poll() do
						if name == 'quit' then
							if not love.quit or not love.quit() then
								return a
							end
						end

						love.handlers[name](a, b, c, d, e, f)
					end
				end

				tickModule.tick = tickModule.tick + 1
				if love.update then love.update(tickModule.rate) end
			end
		else
			if love.event then
				love.event.pump()
				for name, a, b, c, d, e, f in love.event.poll() do
					if name == 'quit' then
						if not love.quit or not love.quit() then
							return a
						end
					end

					love.handlers[name](a, b, c, d, e, f)
				end
			end
		end

		while tickModule.framerate and timer.getTime() - lastframe < 1 / tickModule.framerate do
			timer.sleep(.0005)
		end

		lastframe = timer.getTime()
		if isDraw then
			-- graphics.clear(graphics.getBackgroundColor())
			-- graphics.origin()
			tickModule.frame = tickModule.frame + 1
			if love.draw then love.draw() end
			graphics.present()
		end

		timer.sleep(tickModule.sleep)
	end
end

return tickModule
