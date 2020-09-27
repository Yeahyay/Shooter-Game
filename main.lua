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

local PATH = love.filesystem.getSource()
local SAVEDIR = love.filesystem.getSaveDirectory()
print("PATH: "..PATH)
print("SAVEDIR: "..SAVEDIR)

-- require("PepperFishProfiler")
PROFILER = nil--newProfiler()

DEBUG_LEVEL = 0
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
	local printOld = print
	function print(...)
		printOld("OLD PRINT", ...)
	end
end

-- BOOTSTRAP
FeintEngine = require("Feint_Engine.bootstrap")
