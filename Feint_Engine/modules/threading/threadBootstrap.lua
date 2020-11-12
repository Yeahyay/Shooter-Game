local args = {...}

local self = args[1]
-- self.running = true

-- INIT
-- luacheck: push ignore
do	-- DEFAULT FILTERS
	defaultGlobals = {}
	for k, v in pairs(_G) do
		defaultGlobals[k] = v
	end
	defaultPackages = {}
	for k, v in pairs(package.loaded) do
		defaultPackages[k] = v
	end
	defaultAll = {}
	for k, v in pairs(_G) do
		if string.match(k, "default") then
			for k, v in pairs(v) do
				defaultAll[k] = v
			end
		end
	end
end
-- luacheck: pop ignore

_ENV = _G
_ENV_LAST = _G
_TYPE = "THREAD"
_LAYER = 0
_REQUIRE_SILENT = false
_NAME = string.format("THREAD_%02d", self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

-- print(love.timer)
love.timer = require("love.timer")
love.system = require("love.system")

require("Feint_Engine.feintAPI", {Audio = true})

-- local loadfile = Feint.Util.Memoize(loadfile)

-- Feint.LoadModule("Input")
Feint.LoadModule("ECS")
-- Feint.LoadModule("Graphics")
-- Feint.LoadModule("Parsing")
-- Feint.LoadModule("Serialize")
-- Feint.LoadModule("Audio")
-- Feint.LoadModule("Tween")
-- Feint.LoadModule("UI")


local jobCode = {}
local loadJob = function(data, type)
	if not jobCode[data] then
		if type == "string" then
			jobCode[data] = loadstring(data)
		elseif type == "file" then
			jobCode[data] = loadfile(data)
		elseif type == "function" then
			jobCode[data] = data
		end
	end
	return jobCode[data]
end

do
	local printOld = print
	function print(...)
		printf("%s_OLD: ", _NAME)
		printOld(...)
	end
end

-- function printf(format, ...)
-- 	if format then
-- 		io.write(string.format(format or "", ...))
-- 	else
-- 		io.write("")
-- 	end
-- end

local loop = coroutine.wrap(function(data, ...)
	while true do
		local func = loadJob(data.func, data.type)
		func("poop")
		coroutine.yield()
	end
end)

Feint.Log.logln("thread done")
-- send response to main thread
channel:push(true)

local status = channel:demand()
-- wait for acknowledgement
Feint.Log.logln(status)

while true do
	local data = false
	Feint.Log.logln("WAITING FOR FUNCTION")
	repeat
		data = channel:demand()
	until data
	Feint.Log.logln(data)

	if data.go then
		loop.resume(data)
	end
end
