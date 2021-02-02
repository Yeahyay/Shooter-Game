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

	local jobQueuePointer = 0
	local jobQueue = setmetatable({}, {
		__index = {
			insert = function(self, item)
				jobQueuePointer = jobQueuePointer + 1
				self[jobQueuePointer] = item
			end;
			peek = function(self)
				return self[jobQueuePointer]
			end;
			remove = function(self)
				if jobQueuePointer > 0 then
					local item = self[jobQueuePointer]
					jobQueuePointer = jobQueuePointer - 1
					return item
				else
					return nil
				end
			end;
			size = function(self)
				return jobQueuePointer
			end;
		}
	})

	function self:queue(archetype, archetypeChunk, operation)
		local s = ffi.string(
			archetypeChunk.data,
			archetypeChunk.numEntities * archetypeChunk.entitySizeBytes
		)
		local job = {
			id = jobQueue:size() + 1,
			tick = Feint.Core.Time.tick,

			entityByteData = archetypeChunk.byteData,
			structDefinition = archetypeChunk.structDefinition,
			archetypeString = archetype.archetypeString,
			archetypeChunkIndex = archetypeChunk.index,
			entityIndexToId = archetypeChunk.entityIndexToId,
			sizeBytes = archetypeChunk.numEntities * archetypeChunk.entitySizeBytes,

			dataString = s, --love.data.newByteData(s),
			rangeMin = 0,
			rangeMax = archetypeChunk.numEntities - 1,
			length = archetypeChunk.numEntities,
			operation = string.dump(operation),
		}

		jobQueue:insert(job)

		-- local jobs =  self:splitJob(job, numWorkers)
		-- for i = 1, #jobs, 1 do
		-- 	jobQueue:insert(jobs[i])
		-- 	-- jobQueue[jobQueue:size() + 1] = jobs[i]
		-- end
	end

	function self:splitJob(job, slices)
		local jobs = {}
		local dx = math.floor(job.rangeMax / slices)
		for i = 1, slices, 1 do
			jobs[#jobs + 1] = {
				id = job.id + i - 1,
				tick = Feint.Core.Time.tick,

				entityByteData = job.entityByteData,
				archetypeString = job.archetypeString,
				archetypeChunkIndex = job.archetypeChunkIndex,
				entityIndexToId = job.entityIndexToId,
				sizeBytes = job.sizeBytes,

				dataString = job.dataString, --love.data.newByteData(s),
				rangeMin = (i - 1) * dx,
				rangeMax = math.min(i * dx, job.length) - 1,
				length = job.length,
				operation = job.operation,
			}
		end
		return jobs
	end

	function self:sendJob(job, workerID)
		-- assert(job, "no job given", 3)
		local channel = workers[workerID].channel

		-- Feint.Log:logln("Sending job %d range %d - %d to worker thread %d", job.id, job.rangeMin, job.rangeMax, workerID)
		channel:push(ENUM_THREAD_NEW_JOB)
		channel:push(job)
	end

	local DefaultWorld = Feint.ECS.World.DefaultWorld
	local DefaultWorldEntityManager = DefaultWorld.EntityManager

	if not isThread then
		love.handlers["thread_finished_job"] = function(a) -- luacheck: ignore
			local channel = workers[a].channel
			channel:pop()
			-- local job = channel:demand()

			if jobQueue:size() > 0 then
				self:sendJob(jobQueue:remove(), a)
			else
				-- Feint.Log:logln("no more jobs available")
				channel:push(ENUM_THREAD_NO_JOBS)
			end
		end
		love.handlers["thread_finished"] = function(a) -- luacheck: ignore
			local channel = workers[a].channel
			channel:demand()
			-- printf("THREAD %d COMPLETED\n", a)
		end
	end

	function self:update()
		local activeThreads = 0

		-- Feint.Log:logln("%d jobs queued", jobQueue:size())
		for i = 1, math.min(jobQueue:size(), self:getNumWorkers()), 1 do
			self:sendJob(jobQueue:remove(), i)
			activeThreads = activeThreads + 1
		end

		while activeThreads > 0 do
			for n, a in love.event.poll() do
				if n == "thread_finished_job" then
					-- local channel = workers[a].channel
					love.handlers["thread_finished_job"](a) -- luacheck: ignore
				elseif n == "thread_finished" then
					activeThreads = activeThreads - 1
					love.handlers["thread_finished"](a) -- luacheck: ignore
				end
			end
			love.timer.sleep(1 / 1000)
		end

		-- Feint.Log:logln("ALL JOBS DONE")
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
		local threadObject = workers[workerID]
		threadObject.thread:start(string.dump(_G.initEnv), threadObject, ...)
	end
end

return threading
