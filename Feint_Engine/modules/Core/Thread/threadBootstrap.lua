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

local function execute(arguments, archetype, callback)
	local archetypeChunks = self.archetypeChunks
	local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
	local a1Name, a2Name = a1.Name, a2.Name
	local a3Name, a4Name = a3.Name, a4.Name
	local a5Name, a6Name = a5.Name, a6.Name

	for i = 1, self.archetypeChunksCount[archetype], 1 do
		local archetypeChunk = archetypeChunks[archetype][i]
		local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

		for j = archetypeChunk.numEntities - 1, 0, -1 do
			callback(
				data[j][a1Name], data[j][a2Name],
				data[j][a3Name], data[j][a4Name],
					data[j][a5Name], data[j][a6Name]
				)
			end
		end
	end
local function executeEntity(arguments, archetype, callback)
	local archetypeChunks = self.archetypeChunks
	local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
	local a3Name, a4Name = a3.Name, a4.Name

	for i = 1, self.archetypeChunksCount[archetype], 1 do
		local archetypeChunk = archetypeChunks[archetype][i]
		local idList = archetypeChunk.entityIndexToId
		local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

		for j = archetypeChunk.numEntities - 1, 0, -1 do
			callback(idList[j + 1], data[j][a3Name], data[j][a4Name])
		end
	end
end
local function executeEntityAndData(arguments, archetype, callback)
	local archetypeChunks = self.archetypeChunks
	local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
	local a3Name, a4Name = a3.Name, a4.Name

	for i = 1, self.archetypeChunksCount[archetype], 1 do
		local archetypeChunk = archetypeChunks[archetype][i]
		local idList = archetypeChunk.entityIndexToId
		local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

		for j = archetypeChunk.numEntities - 1, 0, -1 do
			callback(data, idList[j + 1], data[j][a3Name], data[j][a4Name])
		end
	end
end

local componentCache = {}
local function forEach(id, callback)
	-- get the function arguments and store them as an array of strings
	if not componentCache[id] then
		componentCache[id] = {}

		local funcInfo = debug.getinfo(callback)
		local i = 1
		for j = 1, funcInfo.nparams, 1 do
			local componentName = debug.getlocal(callback, j)
			if componentName ~= "Data" and componentName ~= "Entity" then
				local component = self.World.components[componentName]
				if component.componentData then
					assert(component, string.format("arg %d (%s) is not a component", i, componentName), 2)
					componentCache[id][i] = component
					i = i + 1
				end
			else
				componentCache[id][i] = componentName
				i = i + 1
			end
		end
	end

	-- convert the array of strings into an archetypeString
	local archetypeString = self:getArchetypeStringFromComponents(componentCache[id])
	-- use the string to execute the callback on its respective archetype chunks
	self:execute(componentCache[id], self.archetypes[archetypeString], callback)
end

local function performJob(job, entities)
	local entityIndexToId = job.entityIndexToId
	local operation = load(job.operation)
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
		-- Feint.Log:logln("finished job %d", jobData.id)
		-- channel:supply(jobData)
	elseif status == ENUM_THREAD_NO_JOBS then -- luacheck: ignore
		-- Feint.Log:logln("No more jobs, idling")
		love.event.push("thread_finished", self.id)
		channel:supply(ENUM_THREAD_FINISHED)
	end
	-- love.thread.getChannel("MAIN_BLOCK"):supply(1)
	-- print("skldnksd", love.thread.getChannel("MAIN_BLOCK"):getCount())
	-- love.thread.getChannel("MAIN_BLOCK"):push(0)
end
