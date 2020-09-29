local thread = {}

local workers = {}

function thread.newWorker(id, func)
	log("Creating new worker thread \"THREAD_%02d\"\n", id)
	local thread = {
		thread = love.thread.newThread(Feint.Paths.SlashDelimited(Feint.Paths.Thread) .. "systemWorker.lua"),
		id = not workers[id] and id or #workers + 1,
		running = false,
		channel = love.thread.getChannel("thread_data_" .. id),

		-- start = function(self, ...)
		-- 	self.thread:start(...)
		-- end,
	}
	-- print(thread.id, thread.func)
	workers[#workers + 1] = thread
	return thread
end

function thread.startWorker(threadID, ...)
	-- print(workers[threadID].thread)
	local thread = workers[threadID]
	thread.thread:start(thread, ...)
end

return thread
