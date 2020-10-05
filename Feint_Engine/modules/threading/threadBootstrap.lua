local args = {...}

local self = args[1]
-- self.running = true

-- INIT
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
			-- print(k)
			for k, v in pairs(v) do
				defaultAll[k] = v
			end
		end
	end
end

_ENV = _G
_ENV_LAST = _G
_TYPE = "THREAD"
_LAYER = 0
_REQUIRE_SILENT = false
_NAME = string.format("THREAD_%02d", self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

require("Feint_Engine.feintAPI", {Audio = true})

love.timer = require("love.timer")

-- local loadfile = Feint.Util.Memoize(loadfile)

local jobCode = {}
local loadJob = Feint.Util.Memoize(function(data, type)
	if type == "string" then
		jobCode[data] = loadstring(data)
	elseif type == "file" then
		jobCode[data] = loadfile(data)
	end
end)

do
	local printOld = print
	function print(...)
		printf("%s_OLD: ", _NAME)
		printOld(...)
	end
end

local loop = coroutine.create(loadfile())

while self.running do

	print("rgjndsfkm")
end
