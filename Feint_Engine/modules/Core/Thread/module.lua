local threading = {
	depends = {"Core", "Core.Paths",
	"ECS" --[[TEMPORARY]]}
}

local ffi = require("ffi")
function threading:load(isThread)
	require("love.system")

	-- Feint.Core.Paths:Print()

	Feint.Core.Paths:Add("Thread", Feint.Core.Paths.Core .. "Thread")

	local workers = {}
	local numWorkers = 0

	-- require("love.system")

	local ENUM_THREAD_FINISHED = 0
	local ENUM_THREAD_NO_JOBS = 1
	local ENUM_THREAD_NEW_JOB = 2
	local ENUM_THREAD_FINISHED_JOB = 3
	local ENUM_THREAD_QUERY_STATUS = 4
	local ENUM_THREAD_STATUS_BUSY = 5

	--[[
		A job queue is maintained before every job system update.
		Every update, threads are provided jobs at a first come first serve basis.
		THREAD CODES:
		0 - thread finished
		1 - no more jobs
		2 - thread new job
		3 - thread finished job
		4 - query thread status
		5 - thread busy

		Example
		Thread 0 spawns 3 threads
		Thread 3 waits for next job - returns 0
		Thread 1 waits for next job - returns 0
		Thread 2 waits for next job - returns 0
		Thread 0 all threads returned 0, ready for next update

		:LOOP:
		Thread 0 recieves 5 job queues
		Thread 0 has 5 jobs
		Thread 1 gets job 1
		Thread 3 gets job 2
		Thread 2 gets job 3
		Thread 2 finishes - returns 3 to Thread 0
		Thread 0 recieves it
		Thread 0 sends Thread 2 job 4
		Thread 1 finishes - returns 3 to Thread 0
		Thread 0 recieves it
		Thread 0 sends Thread 1 job 5
		Thread 3 finishes - returns 3 to Thread 0
		Thread 0 recieves it
		Thread 0 has no more jobs - returns 1 to Thread 3
		Thread 2 finishes - returns 3 to Thread 0
		Thread 3 recieves it
		Thread 3 waits for next job - returns 0 to Thread 0
		Thread 0 recieves it
		Thread 0 has no more jobs - returns 1 to Thread 2
		Thread 2 recieves it
		Thread 2 waits for next job - returns 0 to Thread 0
		Thread 0 has waited a while for Thread 1 to finish Job 5 - returns 4 to Thread 1
		Thread 1 recieves it
		Thread 1 is still busy, performance is now garbage - returns 5 to Thread 0
		Thread 0 recieves it, RIP performance
		Thread 0 notifies me my programming is garbage and waits for Thread 1
		Thread 1 finishes - returns 3 to Thread 0
		Thread 0 recieves it
		Thread 0 has no more jobs - returns 1 to Thread 2
		Thread 1 recieves it
		Thread 1 waits for next job - returns 0 to Thread 0
		Thread 0 all threads returned 0, ready for next update
		:LOOP:
	]]

	self.MAX_CORES = love.system.getProcessorCount()

	local jobQueue = {}

	function self:queue(archetype, archetypeChunk, operation)
		local s = ffi.string(
			archetypeChunk.data,
			archetypeChunk.numEntities * archetypeChunk.entitySizeBytes
		)
		local job = {
			id = #jobQueue + 1,
			tick = Feint.Core.Time.tick,

			archetypeString = archetype.archetypeString,
			archetypeChunkIndex = archetypeChunk.index,
			entityIndexToId = archetypeChunk.entityIndexToId,
			sizeBytes = archetypeChunk.numEntities * archetypeChunk.entitySizeBytes,

			entities = s, --love.data.newByteData(s),
			rangeMin = 0,
			rangeMax = archetypeChunk.numEntities - 1,
			length = archetypeChunk.numEntities,
			operation = string.dump(operation),
		}
		jobQueue[#jobQueue + 1] = job

		-- local jobs =  self:splitJob(job, numWorkers)
		-- for i = 1, #jobs, 1 do
		-- 	jobQueue[#jobQueue + 1] = jobs[i]
		-- end
	end

	function self:splitJob(job, slices)
		local jobs = {}
		local dx = math.floor(job.rangeMax / slices)
		for i = 1, slices, 1 do
			jobs[#jobs + 1] = {
				id = job.id + i - 1,
				tick = Feint.Core.Time.tick,

				archetypeString = job.archetypeString,
				archetypeChunkIndex = job.archetypeChunkIndex,
				entityIndexToId = job.entityIndexToId,
				sizeBytes = job.sizeBytes,

				entities = job.entities, --love.data.newByteData(s),
				rangeMin = (i - 1) * dx,
				rangeMax = math.min(i * dx, job.length) - 1,
				length = job.length,
				operation = job.operation,
			}
		end
		return jobs
	end

	function self:sendJob(job, workerID)
		local channel = workers[workerID].channel

		Feint.Log:logln("Sending job %d range %d - %d to worker thread %d", job.id, job.rangeMin, job.rangeMax, workerID)
		channel:push(ENUM_THREAD_NEW_JOB)
		channel:push(job)
	end

	-- require("love.event")

	local DefaultWorld = Feint.ECS.World.DefaultWorld
	local DefaultWorldEntityManager = DefaultWorld.EntityManager

	if not isThread then
		love.handlers["thread_finished_job"] = function(a) -- luacheck: ignore
			-- printf("THREAD %d COMPLETED JOB\n", a)
			local channel = workers[a].channel
			channel:pop()
			local job = channel:demand()
			-- Feint.Log:logln("Channel %d data: %s", a, tostring(job))

			local arc = Feint.ECS.World.DefaultWorld.EntityManager.archetypes[job.archetypeString]
			local chunk = Feint.ECS.World.DefaultWorld.EntityManager.archetypeChunks[arc][a]

			ffi.copy(chunk.data, job.entities, job.sizeBytes)

			if #jobQueue > 0 then
				-- print(#jobQueue)
				self:sendJob(jobQueue[#jobQueue], a)
				jobQueue[#jobQueue] = nil
				-- print(#jobQueue)
			else
				Feint.Log:logln("no more jobs available")
				channel:push(ENUM_THREAD_NO_JOBS)
			end
		end
		love.handlers["thread_finished"] = function(a) -- luacheck: ignore
			local channel = workers[a].channel
			channel:demand()
			-- print(channel:pop())
			-- printf("THREAD %d COMPLETED\n", a)
		end
	end

	function self:update()
		local activeThreads = 0--self:getNumWorkers()
		-- for k, v in pairs(love.handlers) do
		-- 	print(k, v)
		-- end
		-- printf("\n")
		Feint.Log:logln("%d jobs queued", #jobQueue)
		for i = 1, math.min(#jobQueue, self:getNumWorkers()), 1 do
			-- Feint.Log:logln("Sending job to thread %d", i)
			self:sendJob(jobQueue[#jobQueue], i)
			jobQueue[#jobQueue] = nil
			activeThreads = activeThreads + 1
		end
		-- for i = 1, 100, 1 do
		while activeThreads > 0 do
		-- for n, a, b, c, d, e, f in love.event.poll() do
			-- if n == "thread_finished_job" then
			-- 	break
			-- end
			-- if activeThreads <= 0 then
				-- Feint.Log:logln("All Threads Inactive")
				-- break
			-- end

			-- local status
			-- local chunkData
			-- Feint.Log:logln("POLLING")

			-- love.event.push("thread_finished_job", 1)
			for n, a in love.event.poll() do
				if n == "thread_finished_job" then
					local channel = workers[a].channel
					love.handlers["thread_finished_job"](a)
				elseif n == "thread_finished" then
					activeThreads = activeThreads - 1
					love.handlers["thread_finished"](a)
				end
			end
			love.timer.sleep(1 / 1000)
		end
		-- ::hard_end::
		Feint.Log:logln("ALL JOBS DONE")
	end

	function self:newWorker(id)
		-- Feint.Log:log("Creating new worker thread \"THREAD_%02d\"\n", id)
		local newThread = {
			thread = love.thread.newThread(Feint.Core.Paths:SlashDelimited(Feint.Core.Paths.Thread) .. "threadBootstrap.lua"),
			id = not workers[id] and id or #workers + 1,
			running = false,
			channel = love.thread.getChannel("thread_data_" .. id),

			-- start = function(self, ...)
			-- 	self.thread:start(...)
			-- end,
		}

		-- print(thread.id, thread.func)
		numWorkers = numWorkers + 1
		workers[#workers + 1] = newThread
		return newThread
	end

	function self:getWorkers()
		return workers
	end
	function self:getNumWorkers()
		return numWorkers
	end

	function self:startWorker(workerID, ...)
		-- print(workers[workerID].thread)
		local threadObject = workers[workerID]
		threadObject.thread:start(string.dump(_G.initEnv), threadObject, ...)
	end
end

return threading
