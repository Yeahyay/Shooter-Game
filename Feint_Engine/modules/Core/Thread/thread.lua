local thread = {}

function thread:new(...)
	local newThread = {}

	setmetatable(newThread, {
		__index = self
	})

	self.init(newThread, ...)

	return newThread
end

function thread:init(main, id)
	if main then
		self.isMain = true
	end
	self.id = id or -1
	self.running = false

	self.channel = love.thread.getChannel("thread_data_" .. id)
	do
		local path = Feint.Core.Paths:SlashDelimited(Feint.Core.Paths.Thread) .. "threadBootstrap.lua"
		self.threadObject = love.thread.newThread(path);
	end

	self.jobs = {} -- should usually just be one job
end

function thread:queueJob(job)
	self.jobs[#self.jobs + 1] = job
end

local enum = Feint.Core.Thread.ENUM

function thread:sendJobs()
	-- assert(job, "no job given", 3)
	local channel = self.channel

	-- Feint.Log:logln("Sending job %d range %d - %d to worker thread %d", job.id, job.rangeMin, job.rangeMax, workerID)
	channel:push(enum.ENUM_THREAD_NEW_JOB)
	local success = channel:supply(self.jobs[1], 0.5)
	if not success then
		Feint.Log:logln("THREAD %d DESYNC'D", self.id)
		Feint.Core.Time:pause()
	end
end

function thread:start(...)
	self.threadObject:start(self, string.dump(_G.initEnv), ...)
end

function thread:execute()

end

return thread
