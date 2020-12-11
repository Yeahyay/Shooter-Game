local args = {...}

local FEINT_ROOT = args[1]:gsub("feintAPI", "")

-- require("love.audio")
-- require("love.data")
-- require("love.event")
-- require("love.filesystem")
-- require("love.font")
-- require("love.graphics")
-- require("love.image")
-- require("love.joystick")
-- require("love.keyboard")
-- require("love.math")
-- require("love.mouse")
-- require("love.physics")
-- require("love.sound")
-- require("love.system")
-- require("love.thread")
-- require("love.timer")
-- require("love.touch")
-- require("love.video")
-- require("love.window")

--[[ CREATE A MODULE SYSTEM
|- MODULE_NAME
|  |- module.lua
|  |- whatever else
--]]

Feint = {}--require(FEINT_ROOT .. "modules.core.module")

local modules = {} -- luacheck: ignore
local root = FEINT_ROOT:gsub("%.", "/") .. "modules/"
for _, moduleFolder in pairs(love.filesystem.getDirectoryItems(root)) do
	-- if moduleFolder ~= "core" then
		for k, v in pairs(love.filesystem.getDirectoryItems(root .. moduleFolder)) do
			if v == "module.lua" then
				local path = root .. moduleFolder .. "/" .. v:gsub(".lua", "")
				print(path)
				local module = require(path)
				Feint[moduleFolder] = module
			end
		end
	-- end
end

for k, v in pairs(Feint) do
	print(k, v)
end

-- PATHS
-- To use the path system, I need the path to it; ironic
-- Feint.AddModule("Paths", function(self) -- give it the root as well
-- 	self.require("Feint_Engine.modules.paths", FEINT_ROOT)
-- 	self.Add("Modules", Feint.Paths.Root .. "modules")
-- 	self.Add("Lib", Feint.Paths.Root .. "lib")
-- 	self.Add("Archive", Feint.Paths.Root .. "archive")
-- 	self.Finalize()
-- end)
-- Feint.LoadModule("Paths")
-- Feint.Paths.Print()

-- local mt = getmetatable(Feint)
-- mt.__newindex = function(t, k, v)
-- 	if t[k] then
-- 		t[k] = v
-- 	else
-- 		error(string.format("Module \"%s\" does not exist in Feint\n", k))
-- 	end
-- end
