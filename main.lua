-- INIT
-- require("lib.console.console")
io.stdout:setvbuf("no")
function luaInfo()
	local info = "Lua version: " .. _VERSION .. "\n"
	info = info .. "LuaJIT version: "
	if (jit) then
		info = info .. jit.version
	else
		info = info .. "this is not LuaJIT"
	end
	return info
end

jit.off()
-- jit.on()

print(luaInfo())
print(love.getVersion())
print()

defaultGlobal = {}
for k, v in pairs(_G) do
	defaultGlobal[k] = v
end
defaultPackage = {}
for k, v in pairs(package.loaded) do
	defaultPackage[k] = v
end

local PATH = love.filesystem.getSource()
local SAVEDIR = love.filesystem.getSaveDirectory()
-- print("PATH: "..PATH)
-- print("SAVEDIR: "..SAVEDIR)

-- require("PepperFishProfiler")
PROFILER = nil--newProfiler()

debugLevel = 0
_ENV = _G
_ENV_LAST = _G
_TYPE = "SOURCE" -- or MODULE
_LAYER = 0
_REQUIRE_SILENT = false
_NAME = "GLOBAL TABLE"

function math.clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

do
	local _print = print
	function print(...)
		_print("OLD PRINT", ...)
	end
	printOld = _print
end

SRC_PATH = "src."
LIB_PATH = "lib."

-- BOOTSTRAP

FeintEngine = require("Feint_Engine.bootstrap")

--[[
local coreUtil = require("Feint_Engine.coreUtilities")

local test1 = {}
local test2 = {}
local test2LUT = {}

local times = 1000000
local t = {}
for i = 1, times do
	t[i] = {}--"id"..i
end
for i = times, 1, -1 do
	test1[t[i]
	] = i * 20
end
local function get1(i)
	local lut = t[i]
	local ret = test1[lut]
	-- print(i, ret)
	return ret
end
for i = 1, times do
	test2[i] = "id"..i
	test2LUT[test2[i]
	] = i * 20
end
local function get2(i)
	local lut = t[i]
	local ret = test2LUT[test2[i]
	]
	-- print(i, ret)
	return ret
end
local function performance(num, func)
	local time = {}
	for i = 1, num do
		local startTime = love.timer.getTime()
		func()
		local endTime = love.timer.getTime()
		time[i] = endTime - startTime
	end
	local avg = 0
	for i = 1, #time do
		avg = avg + time[i] / #time
		printf("time: %f\n", time[i]);
	end
	printf("avg time: %f\n", avg);
end

performance(10, function()
	for i = 1, times do
		get1(i)
	end
end)
performance(10, function()
	for i = 1, times do
		get2(i)
	end
end)
performance(10, function()
	for k, v in pairs(test1) do
		local l
	end
end)
performance(10, function()
	for k, v in pairs(test2) do
		local l
	end
end)

--[[
local numStuff = 600000
local oop = {
	val1 = 1,
	val2 = 4,
	val5 = {1, 2},
	ref = nil,
	ref2 = nil,
	ref3 = nil,
	update = function(self, i)
		self.ref:update()
		if self.val2 + love.timer.getTime() > 1 then
			self.val1 = self.val1 + love.timer.getTime()
		end
		self.val2 = self.val2 + i
		self.ref.val3 = self.ref.val4 * 2
		self.val2 = self.val2 - self.ref.val3

		self.val2 = self.val2 * self.val5[1] + self.val5[2]
		self.ref2.val1 = self.ref2.val1 + self.ref3.val1
		self.val2 = self.ref2.val1
		return self.val2 - self.val1
	end
}
local stuffOOP = {}
for i = 1, numStuff, 10 do
	for j = 1, 10 do
		local new2 = setmetatable({}, {
			__index = oop
		})
		new2.val3 = 300
		new2.val4 = 20
		new2.update = function(self)
			self.val3 = self.val3 - love.timer.getTime()
		end

		local new3 = setmetatable({}, {
			__index = nil
		})
		new3.val1 = 300
		-- print("Memory usage: "..collectgarbage("count") / 1024)

		local new4 = setmetatable({}, {
			__index = nil
		})
		new4.val1 = 300

		local new = setmetatable({}, {
			__index = oop
		})
		new.val1 = oop.val1
		new.val2 = oop.val2
		new.ref = new2
		new.ref2 = new3
		new.ref3 = new4
		new.update = oop.update
		stuffOOP[i + j - 1] = new
	end
end

local stuffECS = {}

local chunks = {}
local chunks2 = {}

local stuff = 0
while stuff < numStuff do
	local newChunk = {
		data = {},
		entities = {},
		dataSize = 4,
		size = 2^12
	}

	do
		local currentChunk = newChunk
		for i = 1, currentChunk.size, currentChunk.dataSize do
			local component1 = {
				val1 = 1,
				val2 = 4,
				val5 = {1, 2},
			}
			local component2 = {
				val3 = 300,
				val4 = 20,
			}
			local component3 = {
				val1 = 300,
			}
			local component4 = {
				val1 = 300,
			}
			currentChunk.data[i] = component1
			currentChunk.data[i + 1] = component2
			currentChunk.data[i + 2] = component3
			currentChunk.data[i + 3] = component4

			stuff = stuff + 1
		end
	end

	chunks[#chunks + 1] = newChunk
end

printf("oop\n")
performance(10, function()
	for k, v in ipairs(stuffOOP) do
		v:update(k)
	end
end)

local function testFunc(i, component1, component2, component3, component4)
	if component1.val2 + love.timer.getTime() > 1 then
		component1.val1 = component1.val1 + love.timer.getTime()
	end
	component1.val2 = component1.val2 + i

	component2.val3 = component2.val4 * 2
	component1.val2 = component1.val2 - component2.val3

	component1.val2 = component1.val2 * component1.val5[1] + component1.val5[2]

	component3.val1 = component3.val1 + component4.val1
	component1.val2 = component3.val1
	return component1.val2 - component1.val1
end

local function testFunc2(i, component2)
	component2.val3 = component2.val3 - love.timer.getTime()
end

printf("ecs\n")
performance(10, function()
	for i = 1, #chunks do
		local currentChunk = chunks[i]

		for i = 1, #currentChunk.data, currentChunk.dataSize do
			testFunc2(i, currentChunk.data[i + 1])
		end
	end
	for i = 1, #chunks do
		local currentChunk = chunks[i]

		for i = 1, #currentChunk.data, currentChunk.dataSize do
			testFunc(i, currentChunk.data[i], currentChunk.data[i + 1], currentChunk.data[i + 2], currentChunk.data[i + 3])
		end
	end
end)
--]]
