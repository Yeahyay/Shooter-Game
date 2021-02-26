local threading = {
	depends = {"Core", "Core.Paths",
	"ECS" --[[TEMPORARY]]}
}


local ffi = require("ffi")
function threading:load(isThread)
	require("love.system")

	-- Feint.Core.Paths:Print()

	Feint.Core.Paths:Add("Thread", Feint.Core.Paths.Core .. "Thread")
	local Thread = require(Feint.Core.Paths.Thread .. "thread")
	local Job = require(Feint.Core.Paths.Thread .. "job")

	local threads = {}
	local numThreads = 0

	-- require("love.system")

	self.ENUM = {}
	self.ENUM.THREAD_FINISHED = 0
	self.ENUM.THREAD_NO_JOBS = 1
	self.ENUM.THREAD_NEW_JOB = 2
	self.ENUM.THREAD_FINISHED_JOB = 3
	self.ENUM.THREAD_QUERY_STATUS = 4
	self.ENUM.THREAD_STATUS_BUSY = 5

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

	self.MainThread = Thread:new(true, 0)

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

	function self:queueArchetype(EntityManager, archetype, operation)
		for i = 1, archetype.chunkCount, 1 do
			local archetypeChunk = EntityManager:getArchetypeChunkTableFromArchetype(archetype)[i]

			local job = Job:newFor(
				jobQueue:size() + 1,
				archetypeChunk,
				0,
				archetypeChunk.numEntities - 1,
				nil,
				operation
			)

			jobQueue:insert(job)
		end

		-- local jobs = self:splitJob(job, archetypeChunk, 4)
		-- for i = 1, #jobs, 1 do
		-- 	jobQueue:insert(jobs[i])
		-- 	-- jobQueue[jobQueue:size() + 1] = jobs[i]
		-- end
	end

	function self:queue(archetype, archetypeChunk, arguments, jobData, operation)
		-- if jobQueue:size() >= 2 * numThreads then
		-- 	return nil
		-- end
		local job = Job:newFor(
			jobQueue:size() + 1,
			archetypeChunk,
			0,
			archetypeChunk.numEntities - 1,
			arguments,
			jobData,
			operation
		)

		jobQueue:insert(job)

		-- local jobs = self:splitJob(job, archetypeChunk, 4)
		-- for i = 1, #jobs, 1 do
		-- 	jobQueue:insert(jobs[i])
		-- 	-- jobQueue[jobQueue:size() + 1] = jobs[i]
		-- end
	end

	function self:splitJob(job, archetypeChunk, slices)
		local jobs = {}
		local dx = math.floor(job.rangeMax / slices)
		job.rangeMin = 0
		job.rangeMax = dx

		for i = 1, slices - 1, 1 do
			-- print(job.operation)
			jobs[#jobs + 1] =
			Job:newFor(
				jobQueue:size() + 1,
				archetypeChunk,
				i * dx,
				math.min((i + 1) * dx, archetypeChunk.capacity) - 1,
				job.data,
				job.operation
			)
		end
		return jobs
	end

	function self:sendJob(job, workerID)
		-- assert(job, "no job given", 3)
		local channel = threads[workerID].channel

		-- Feint.Log:logln("Sending job %d range %d - %d to worker thread %d", job.id, job.rangeMin, job.rangeMax, workerID)
		channel:push(self.ENUM.ENUM_THREAD_NEW_JOB)
		local success = channel:supply(job, 0.5)
		if not success then
			Feint.Log:logln("THREAD %d DESYNC'D", workerID)
			Feint.Core.Time:pause()
		end
	end

	if not isThread then
		love.handlers["thread_finished_job"] = function(a) -- luacheck: ignore
		end

		love.handlers["thread_finished"] = function() -- luacheck: ignore
		end

		love.handlers["thread_desync"] = function() -- luacheck: ignore
		end
	end

	function self:startWorkers()
		for i = 1, numThreads do
			threads[i]:start()
		end
	end

	function self:update()
	end

	function self:newWorker(id)
		numThreads = numThreads + 1
		local thread = Thread:new(false, id)
		threads[#threads + 1] = thread
	end

	function self:getWorkers()
		return threads
	end
	function self:getNumWorkers()
		return numThreads
	end
end

return threading
