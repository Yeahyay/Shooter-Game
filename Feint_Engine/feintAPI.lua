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

--[[ Module Format
|- MODULE_NAME
|  |- module.lua
|  |- whatever else
--]]

Feint = {}
Feint.Modules = {
	Name = "MODULE_HEIRARCHY_ROOT"
}
Feint.LoadedModules = {}
setmetatable(Feint, {
	__index = Feint.Modules
})

local moduleLoader = require("Feint_Engine.modules.moduleLoader")
moduleLoader:setRoot(FEINT_ROOT:gsub("%.", "/") .. "modules")
Feint.ModuleLoader = moduleLoader

function Feint:importModule(path)
	moduleLoader:importModule(path)
end

function Feint:importModules()
	local moduleStack = {}
	local moduleStackPointer = 0
	function moduleStack:insert(dir)
		moduleStackPointer = moduleStackPointer + 1
		moduleStack[moduleStackPointer] = dir
	end
	function moduleStack:pop()
		local item = moduleStack[moduleStackPointer]
		moduleStack[moduleStackPointer] = nil
		moduleStackPointer = moduleStackPointer - 1
		return item
	end
	local dir = moduleLoader:getRoot()
	local lim = 0
	while (dir and love.filesystem.getDirectoryItems(dir) and lim < 100) do
		lim = lim + 1
		local items = love.filesystem.getDirectoryItems(dir)
		table.sort(items, function(a, b)
			return a:upper() > b:upper()
		end)
		for i = 1, #items, 1 do
			local item = items[i]
			local path = dir .. "/" .. item

			if love.filesystem.getInfo(path).type == "directory" and not item:find("%.lua") then
				moduleStack:insert(path)
				Feint:importModule(path)
			end
		end

		dir = moduleStack:pop()
	end
end

function Feint:init(isThread)
	print("Importing Modules")
	self:importModules()
	self.IsThread = isThread
	print("Imported Modules")
	print("Loading Modules")
	self.ModuleLoader:loadAllModules({thread = isThread})
	print("Loaded Modules")
end
