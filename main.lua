-- INIT
-- require("lib.console.console")
io.stdout:setvbuf("no")
local function luaInfo()
	local info = "Lua version: " .. _VERSION .. "\n"
	info = info .. "LuaJIT version: "
	if (jit) then
		info = info .. jit.version
	else
		info = info .. "this is not LuaJIT"
	end
	return info
end

-- jit.off()
-- jit.on()

print(luaInfo())
print(love.getVersion())
print()

local PATH = love.filesystem.getSource()
local SAVEDIR = love.filesystem.getSaveDirectory()
print("PATH: "..PATH)
print("SAVEDIR: "..SAVEDIR)
print()

-- luacheck: globals initEnv
function initEnv(id)
	local fenv = getfenv(2)
	fenv.defaultGlobals = {}
	for k, v in pairs(_G) do
		fenv.defaultGlobals[k] = v
	end
	fenv.defaultPackages = {}
	for k, v in pairs(package.loaded) do
		fenv.defaultPackages[k] = v
	end
	fenv.defaultAll = {}
	for k, v in pairs(_G) do
		if string.match(k, "default") then
			-- print(k)
			for k, v in pairs(v) do
				fenv.defaultAll[k] = v
			end
		end
	end
	fenv._DEBUG_LEVEL = 0
	fenv._ENV = _G
	fenv._ENV_LAST = _G
	fenv._TYPE = "SOURCE" -- or MODULE
	fenv._LAYER = 0
	fenv._REQUIRE_SILENT = false
	fenv._NAME = string.format("THREAD_%02d", id)
end

-- require("PepperFishProfiler")
-- PROFILER = nil--newProfiler()

initEnv(0)

-- BOOTSTRAP

require("Feint_Engine.init")

require(Feint.Core.Paths.Root.."run")
