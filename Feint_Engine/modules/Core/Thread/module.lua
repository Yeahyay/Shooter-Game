local threading = {
	depends = {"Core.Paths"}
}

function threading:load()
	require("love.system")

	Feint.Core.Paths.Add("Thread", Feint.Core.Paths.Modules .. "threading")

	local workers = {}

	-- require("love.system")

	self.MAX_CORES = love.system.getProcessorCount()

	function self:newWorker(id)
		Feint.Log.log("Creating new worker thread \"THREAD_%02d\"\n", id)
		local newThread = {
			thread = love.thread.newThread(Feint.Core.Paths.SlashDelimited(Feint.Core.Paths.Thread) .. "threadBootstrap.lua"),
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

	function self:getWorkers()
		return workers
	end

	function self:startWorker(threadID, ...)
		-- print(workers[threadID].thread)
		local threadObject = workers[threadID]
		threadObject.thread:start(string.dump(_G.initEnv), threadObject, ...)
	end
end

return threading
