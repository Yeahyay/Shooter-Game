local args = {...}

local initEnv = load(args[1])
local self = args[2]

initEnv(self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

local ffi = require("ffi")
require("Feint_Engine.feintAPI", {Audio = true})
Feint:init(true)
Feint.ECS:init()
pushPrintPrefix(string.format("THREAD_%02d", self.id), true)

local ENUM_THREAD_FINISHED = 0
local ENUM_THREAD_NO_JOBS = 1
local ENUM_THREAD_NEW_JOB = 2
local ENUM_THREAD_FINISHED_JOB = 3
local ENUM_THREAD_QUERY_STATUS = 4
local ENUM_THREAD_STATUS_BUSY = 5

-- send response to main thread and wait
Feint.Log:logln("RESPONDING")
channel:supply(ENUM_THREAD_FINISHED)

local componentCache = {}

local function performJob(job, entities)
	local entityIndexToId = job.entityIndexToId
	local operation = load(job.operation)
	local a = 0
	local b = love.timer.getTime()

	-- for k, v in pairs(job) do print(k, v) end
	print(job.data)

	local data = {}
	if job.data then
		load(job.data)(data)
	end
	for i = job.rangeMin, job.rangeMax, 1 do
		-- print(i, "j93r-feinojnipk")
		-- operation(entityIndexToId[i], entities[i])
		a = a + a * b
		operation(data, i, entities[i].Renderer, entities[i].Transform)
		-- love.timer.sleep(1 / 1500)
	end
	-- print(a)
end

local cstring = ffi.typeof("cstring")
Feint.Log:logln("Thread done")

local function abort(from, jobData)
	love.event.push("thread_desync", self.id, from, jobData)
end

while true do
	-- Feint.Core.Time:update()
	local status
	repeat
		printf("pre  %s: %s, %d\n", type(channel:peek()), channel:peek(), channel:getCount())
		status = channel:demand(2)--Feint.Core.Time.rate)

		local success = status and true or false
		if not success then
			abort("waiting for job", -1)
			goto ABORT
		end
		printf("got  %s: %s, %d\n", type(status), status, channel:getCount())
	until type(status) == "number" and (status ~= ENUM_THREAD_FINISHED and status ~= ENUM_THREAD_FINISHED_JOB)
	printf("done %s: %s, %d\n", type(channel:peek()), channel:peek(), channel:getCount())
	if status == ENUM_THREAD_NEW_JOB then
		local jobData
		jobData = channel:demand(1)
		printf("post %s: %s, %d\n", type(channel:peek()), channel:peek(), channel:getCount())

		local success = jobData and true or false
		if not success then
			abort("doing job", jobData)
			goto ABORT
		end

		Feint.Log:logln("Thread %d job data: %s", self.id, jobData)
		Feint.Log:logln("got job %d at %f", jobData.id, love.timer.getTime())

		local entities = ffi.cast(jobData.structDefinition, jobData.entityByteData:getFFIPointer())
		local startTime = love.timer.getTime()
		performJob(jobData, entities)
		local endTime = love.timer.getTime() - startTime
		-- print(Feint.ECS.execute1)

		Feint.Log:logln("finished job %d in %0.4f ms, sending jobData back", jobData.id, endTime * 1000)

		love.event.push("thread_finished_job", self.id)
		channel:supply(ENUM_THREAD_FINISHED_JOB)
		-- Feint.Log:logln("finished job %d", jobData.id)
	elseif status == ENUM_THREAD_NO_JOBS then -- luacheck: ignore
		love.event.push("thread_finished", self.id)
		channel:supply(ENUM_THREAD_FINISHED)
	end

	::ABORT::
	-- channel:demand()
end

-- while true do
-- 	local status
--
-- 	Feint.Log:logln("waiting for a job")
-- 	repeat
-- 		printf("pre  %s: %s, %d\n", type(channel:peek()), status, channel:getCount())
-- 		-- love.timer.sleep(0.1)
-- 		status = channel:demand(0.1)--Feint.Core.Time.rate)
-- 		-- status = channel:peek()
-- 		-- printf("status (%s) \"%s\" channel (%s) \"%s\"\n", status, type(status), channel:peek(), type(channel:peek()))
-- 		printf("post %s: %s, %d\n", type(status), status, channel:getCount())
-- 	until type(status) == "number" and (status ~= ENUM_THREAD_FINISHED and status ~= ENUM_THREAD_FINISHED_JOB)
-- 	-- printf("status (%s) \"%s\" channel (%s) \"%s\"\n", status, type(status), channel:peek(), type(channel:peek()))
-- 	printf("post %s: %s, %d\n", type(status), status, channel:getCount())
-- 	love.event.push("thread_finished_job", self.id)
-- 	channel:pop()
--
-- 	Feint.Log:logln("status: %d", self.id, status)
-- 	if status == ENUM_THREAD_NEW_JOB then
-- 		local jobData
-- 		jobData = channel:demand()
-- 		-- Feint.Log:log("RECIEVED %s ", jobData)
-- 		-- printf("tick: %d\n", jobData.tick)
-- 		Feint.Log:logln("Thread %d job data: %s", self.id, jobData)
-- 		Feint.Log:logln("got job %d", jobData.id)
--
-- 		local entities = ffi.cast(jobData.structDefinition, jobData.entityByteData:getFFIPointer())
-- 		performJob(jobData, entities)
--
-- 		-- love.timer.sleep(0.012)
-- 		-- Feint.Log:logln("finished job %d, sending jobData back", jobData.id)
--
--
-- 		love.event.push("thread_finished_job", self.id)
-- 		channel:push(ENUM_THREAD_FINISHED_JOB)
-- 		Feint.Log:logln("finished job %d", jobData.id)
-- 		-- channel:supply(jobData)
-- 	elseif status == ENUM_THREAD_NO_JOBS then -- luacheck: ignore
-- 		Feint.Log:logln("No more jobs, idling")
-- 		love.event.push("thread_finished", self.id)
-- 		channel:supply(ENUM_THREAD_FINISHED)
-- 	end
-- 	-- love.thread.getChannel("MAIN_BLOCK"):supply(1)
-- 	-- print("skldnksd", love.thread.getChannel("MAIN_BLOCK"):getCount())
-- 	-- love.thread.getChannel("MAIN_BLOCK"):push(0)
-- end
