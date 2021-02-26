local args = {...}

local self = args[1]
local initEnv = load(args[2])

initEnv(self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

-- local ffi = require("ffi")
require("Feint_Engine.feintAPI", {Audio = true})
Feint:init(true)
Feint.ECS:init()
pushPrintPrefix(string.format("THREAD_%02d", self.id), true)

-- luacheck: push ignore
local ENUM_THREAD_FINISHED = 0
local ENUM_THREAD_NO_JOBS = 1
local ENUM_THREAD_NEW_JOB = 2
local ENUM_THREAD_FINISHED_JOB = 3
local ENUM_THREAD_QUERY_STATUS = 4
local ENUM_THREAD_STATUS_BUSY = 5
-- luacheck: pop ignore

-- send response to main thread and wait
Feint.Log:logln("RESPONDING")
channel:supply(ENUM_THREAD_FINISHED)

-- local cstring = ffi.typeof("cstring")
Feint.Log:logln("Thread done")

local function abort(from, jobData)
	love.event.push("thread_desync", self.id, from, jobData)
end

while true do
	-- Feint.Log:logln("IDLE")
	love.timer.sleep(1 / 100)
end
