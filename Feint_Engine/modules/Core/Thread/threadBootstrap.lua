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

local function performJob(job, entities)
	local entityIndexToId = job.entityIndexToId
	local operation = loadstring(job.operation)
	for i = job.rangeMin, job.rangeMax, 1 do
		operation(entityIndexToId[i], entities[i])
	end
end

local cstring = ffi.typeof("cstring")
Feint.Log:logln("Thread done")
while true do
	local status

	-- Feint.Log:logln("waiting for a job")
	repeat
		status = channel:demand(10)--Feint.Core.Time.rate)
		-- printf("status (%s) \"%s\" channel (%s) \"%s\"\n", status, type(status), channel:peek(), type(channel:peek()))
		-- printf("%d\n", channel:getCount())
	until type(status) == "number" and (status ~= ENUM_THREAD_FINISHED and status ~= ENUM_THREAD_FINISHED_JOB)
	-- printf("status (%s) \"%s\" channel (%s) \"%s\"\n", status, type(status), channel:peek(), type(channel:peek()))

	-- Feint.Log:logln("Thread %d status: %d", self.id, status)
	if status == ENUM_THREAD_NEW_JOB then
		local jobData
	-- Feint.Log:log("RECIEVED %s ", jobData)
	-- printf("tick: %d\n", jobData.tick)
		jobData = channel:demand()
		-- Feint.Log:logln("Thread %d job data: %s", self.id, jobData)
		-- Feint.Log:logln("got job %d", jobData.id)

		local entities = ffi.cast(jobData.structDefinition, jobData.entityByteData:getFFIPointer())
		performJob(jobData, entities)

		-- love.timer.sleep(0.012)
		-- Feint.Log:logln("finished job %d, sending jobData back", jobData.id)

		love.event.push("thread_finished_job", self.id)
		channel:push(ENUM_THREAD_FINISHED_JOB)
		-- channel:supply(jobData)
	elseif status == ENUM_THREAD_NO_JOBS then -- luacheck: ignore
		-- Feint.Log:logln("No more jobs, idling")
		love.event.push("thread_finished", self.id)
		channel:supply(ENUM_THREAD_FINISHED)
	end
end
