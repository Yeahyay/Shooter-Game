local run = {
	depends = {"Core.Paths"}
}

function run:load()
	local tick = require("Feint_Engine.lib.tick-master.tick")
	setmetatable(self, {
		__index = tick,
		__newindex = tick
	})

	local pauseOffset = 0
	local pauseTimeStart = 0
	local time = 0
	local speed = 1

	function self:update()
		time = time + speed -- time + love.timer.getDelta() * speed
	end
	function self:setSpeed(value)
		speed = value
	end
	function self:getSpeed()
		return speed
	end

	do
		-- local socket = require("socket")
		-- local startTime = love.timer.getTime() - (socket.gettime() % 1)
		function self:getTrueTime()
			return time * self.rate-- startTime
		end
		function self:getTime()
			return self:getTrueTime() + pauseOffset
		end
	end
	function self:setPauseOffset(time)
		pauseOffset = pauseOffset + time
	end


	function self:pause()
		self.paused = true
		pauseTimeStart = self:getTrueTime()
	end
	function self:unpause()
		self.paused = false
		pauseOffset = pauseOffset - (self:getTrueTime() - pauseTimeStart)
	end
	function self:isPaused()
		return self.paused
	end

	self.G_DEBUG = false
	-- G_TIMER = 0

	self.UPDATE_TIME_PERCENT_FRAME = 0
	self.UPDATE_DT = 0
	self.UPDATE_TIME = 0
	self.UPDATE_TIME_SMOOTHNESS = 0.975

	self.RENDER_TIME_PERCENT_FRAME = 0
	self.RENDER_DT = 0
	self.RENDER_TIME = 0
	self.RENDER_TIME_SMOOTHNESS = 0.975

	self.FPS = 0
	self.FPS_DELTA = 0
	self.FPS_DELTA_SMOOTHNESS = 0.975

	self.AVG_FPS = 0
	self.AVG_FPS_DELTA = 0
	self.AVG_FPS_DELTA_ITERATIONS = self.framerate > 0 and self.framerate * 2 or 60

	self.TPS = 0
	self.TPS_DELTA = 0
	self.TPS_DELTA_SMOOTHNESS = 0.9

	self.AVTPS = 0
	self.AVTPS_DELTA = 0
	self.AVTPS_DELTA_ITERATIONS = 60

	self.G_SPEED = 1

	self.G_INT = 0
end

return run
