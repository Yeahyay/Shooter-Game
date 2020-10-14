local thread = {}

local workers = {}

require("love.system")

thread.MAX_CORES = love.system.getProcessorCount()

function thread.newWorker(id)
	log("Creating new worker thread \"THREAD_%02d\"\n", id)
	local newThread = {
		thread = love.thread.newThread(Feint.Paths.SlashDelimited(Feint.Paths.Thread) .. "threadBootstrap.lua"),
		id = not workers[id] and id or #workers + 1,
		running = false,
		channel = love.thread.getChannel("thread_data_" .. id),

		-- start = function(self, ...)
		-- 	self.thread:start(...)
		-- end,
	}

	-- print(thread.id, thread.func)
	workers[#workers + 1] = newThread
	return newThread
end

function thread.getWorkers()
	return workers
end

function thread.startWorker(threadID, ...)
	-- print(workers[threadID].thread)
	local threadObject = workers[threadID]
	threadObject.thread:start(threadObject, ...)
end

return thread
