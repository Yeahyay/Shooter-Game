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
	local startT = Feint.Util.Core.getTime()
	local loadfile = Feint.Util.Memoize(loadfile)
	local func = nil
	for i = 1, 100 do
		func = loadfile("src/ECS/systems/RenderSystem.lua")()
	end
	local endT = Feint.Util.Core.getTime()
	printf("%s: %f frames for loadstring\n", func, (endT - startT) * 60)
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
	threadObject.thread:start(thread, ...)
end

return thread
