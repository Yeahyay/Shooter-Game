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

	function self:createJob(id, archetypeChunk, rangeMin, rangeMax, operation)
		local s = ffi.string(
			archetypeChunk.data,
			archetypeChunk.numEntities * archetypeChunk.entitySizeBytes
		)
		-- assert(operation and type(operation) == "function", "no operation given", 3)
		local job = {
			id = id;
			tick = Feint.Core.Time.tick;

			entityByteData = archetypeChunk.byteData;
			structDefinition = archetypeChunk.structDefinition;
			archetypeString = archetypeChunk.archetype.archetypeString;
			archetypeChunkIndex = archetypeChunk.index;
			entityIndexToId = archetypeChunk.entityIndexToId;
			size = archetypeChunk.numEntities;
			capacity = archetypeChunk.capacity;
			-- sizeBytes = archetypeChunk.numEntities * archetypeChunk.entitySizeBytes;

			dataString = s; --love.data.newByteData(s);
			rangeMin = rangeMin or 0;
			rangeMax = rangeMax or archetypeChunk.numEntities - 1;
			operation = string.dump(operation);
		}
		return job
	end

	function self:queue(archetype, archetypeChunk, operation)
		local job = self:createJob(
			jobQueue:size() + 1,
			archetypeChunk,
			0,
			archetypeChunk.numEntities - 1,
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
			self:createJob(
				jobQueue:size() + 1,
				archetypeChunk,
				i * dx,
				math.min((i + 1) * dx, archetypeChunk.capacity) - 1,
				job.operation
			)
			-- {
			-- 	id = job.id + i - 1,
			-- 	tick = Feint.Core.Time.tick,
			--
			-- 	entityByteData = job.entityByteData,
			-- 	archetypeString = job.archetypeString,
			-- 	archetypeChunkIndex = job.archetypeChunkIndex,
			-- 	entityIndexToId = job.entityIndexToId,
			-- 	sizeBytes = job.sizeBytes,
			--
			-- 	dataString = job.dataString, --love.data.newByteData(s),
			-- 	rangeMin = i * dx,
			-- 	rangeMax = math.min((i + 1) * dx, job.length) - 1,
			-- 	length = job.length,
			-- 	operation = job.operation,
			-- }
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
	local activeThreads = {}
	local activeThreadsCount = 0
	-- local update

	-- love.thread.newChannel("MAIN_BLOCK")
	-- local block = love.thread.getChannel("MAIN_BLOCK")
	if not isThread then
		love.handlers["thread_finished_job"] = function(a) -- luacheck: ignore
			local channel = workers[a].channel
			channel:pop()
			-- local job = channel:demand()

			if jobQueue:size() > 0 then
				self:sendJob(jobQueue:remove(), a)
				-- Feint.Log:logln("%d jobs queued", jobQueue:size())
			else
				-- Feint.Log:logln("no more jobs available")
				channel:push(ENUM_THREAD_NO_JOBS)
			end
		end
		love.handlers["thread_finished"] = function(a) -- luacheck: ignore
			local channel = workers[a].channel
			channel:pop()
			-- printf("THREAD %d COMPLETED\n", a)
			-- activeThreads = activeThreads - 1
			activeThreads[a] = false
			activeThreadsCount = activeThreadsCount - 1
			-- Feint.Log:logln("%d threads active", activeThreadsCount)
			-- if activeThreads <= 0 then
				-- print("DONE DONE DONE DONE")
				-- update()
			-- end
		end
	end

	function self:update()
		-- update()
		-- activeThreadsCount = 0
		-- Feint.Log:logln("%d jobs queued", jobQueue:size())
		for i = 1, math.min(jobQueue:size(), self:getNumWorkers()), 1 do
			self:sendJob(jobQueue:remove(), i)
			if not activeThreads[i] then
				activeThreadsCount = activeThreadsCount + 1
			end
			activeThreads[i] = true
			-- Feint.Log:logln("%d jobs queued", jobQueue:size())
		end
		-- Feint.Log:logln("%d threads active", activeThreadsCount)

		-- [[
		local i = 1
		while activeThreadsCount > 0 and i < 1000 do
			for n, a in love.event.poll() do
				if n == "thread_finished_job" then
					-- local channel = workers[a].channel
					love.handlers["thread_finished_job"](a) -- luacheck: ignore
				elseif n == "thread_finished" then
					love.handlers["thread_finished"](a) -- luacheck: ignore
				end
			end

			love.timer.sleep(1 / 1000)
			-- block:demand(Feint.Core.Time.rate * (1 / (numWorkers * 2)))
			i = i + 1
		end
		--]]

		-- Feint.Log:logln("ALL JOBS DONE")
	end

	function self:newWorker(id)
		-- Feint.Log:log("Creating new worker thread \"THREAD_%02d\"\n", id)
		local newThread = {
			thread = love.thread.newThread(Feint.Core.Paths:SlashDelimited(Feint.Core.Paths.Thread) .. "threadBootstrap.lua");
			id = not workers[id] and id or #workers + 1;
			running = false;
			channel = love.thread.getChannel("thread_data_" .. id);
			main = love.thread.getChannel("MAIN_BLOCK");

			-- start = function(self, ...)
			-- 	self.thread:start(...)
			-- end,
		}

		numWorkers = numWorkers + 1
		workers[#workers + 1] = newThread
		activeThreads[numWorkers] = false
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
