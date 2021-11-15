local ECSUtils = Feint.ECS.Util
local EntityManager = Feint.ECS.EntityManager
local Paths = Feint.Core.Paths

local World = ECSUtils.newClass("World")
function World:init(name)
	self.Name = name
	self.systems = {}
	self.systemsCount = 0
	self.updateOrder = {}
	self.components = {}
	self.EntityManager = EntityManager:new(self)--self.Name .. "EntityManager")
	if love.physics then
		self.PhysicsWorld = love.physics.newWorld(0, 9.82, true)
	end
end

function World:findDirectorySourceFiles(path, extension)
	assert(self ~= World)
	local files = {}
	for fileIndex, fileName in pairs(love.filesystem.getDirectoryItems(path)) do
		local filePath = path .. fileName
		local info = {fileName = fileName, filePath = filePath}
		love.filesystem.getInfo(filePath, info)
		assert(info, "file " .. filePath .. " does not exist")
		if info.type == "file" and (extension and fileName:match(extension) or true) then
			-- print(fileIndex, filePath)
			files[#files + 1] = info
		end
	end
	return files
end

function World:addComponentsFromDirectory(componentsPath)
	self:findDirectorySourceFiles(componentsPath)
	-- local components = {} -- luacheck: ignore
	local componentCount = 0
	for _, fileInfo in pairs(self:findDirectorySourceFiles(componentsPath, ".lua")) do
		local requirePath = fileInfo.filePath:gsub(".lua", "")
		local component = require(requirePath)
		assert(component, "Empty Component file")
		componentCount = componentCount + 1
		self:addComponent(component)
	end
end
function World:addSystemsFromDirectory(systemsPath)
	-- local systems = {} -- luacheck: ignore
	local systemCount = 0
	for _, fileInfo in pairs(self:findDirectorySourceFiles(systemsPath, ".lua")) do
		local requirePath = fileInfo.filePath:gsub(".lua", "")
		local system = require(requirePath)
		assert(system, "Empty System file")
		systemCount = systemCount + 1
		self:addSystem(system)
	end
	-- for k, v in pairs(love.filesystem.getDirectoryItems(systemsPath)) do
	-- 	if v:match(".lua") then
	-- 		local path = Paths.Game_ECS_Components..v:gsub(".lua", "")
	-- 		print(systemsPath, path)
	-- 		local system = require(path)
	-- 		assert(system, "Empty Component file")
	-- 		systemCount = systemCount + 1
	-- 		-- systems[systemCount] = system
	-- 		self:addSystem(system)
	-- 	end
	-- end
end

function World:addComponent(component)
	self.components[component.Name] = component
end

function World:getComponent(name)
	return self.components[name]
end

function World:generateUpdateOrderList()
	local list = {}
	for i = 1, self.systemsCount do
		list[i] = i
	end
	self:setUpdateOrderList(list)
end

function World:setUpdateOrderList(list)
	self.updateOrder = list
end

function World:start()
	local list = self.updateOrder
	local systems = self.systems
	local EntityManager = self.EntityManager
	for i = 1, #list do
		systems[list[i]]:start(EntityManager)
	end
	for i = 1, #list do
		if systems[list[i]].IMGUI_INIT then
			systems[list[i]]:IMGUI_INIT(EntityManager)
		end
	end
	EntityManager:update()
end

function World:update(dt)
	local list = self.updateOrder
	local systems = self.systems
	local EntityManager = self.EntityManager
	for i = 1, #list do
		systems[list[i]]:update(EntityManager, dt)
	end
	EntityManager:update()
end

function World:IMGUI(dt)
	local list = self.updateOrder
	local systems = self.systems
	local EntityManager = self.EntityManager
	for i = 1, #list do
		if systems[list[i]].IMGUI then
			systems[list[i]]:IMGUI(EntityManager, dt)
		end
	end
	-- EntityManager:update()
end

function World:addSystem(system)
	self.systemsCount = self.systemsCount + 1
	self.systems[self.systemsCount] = system
end

function World:destroy()
	self.Name = nil
	self.systems = nil
	self.systemsCount = nil
	self.updateOrder = nil
	self.components = nil
	self.EntityManager:destroy()
end

-- Feint.Util.Table.makeTableReadOnly(World, function(self, k)
-- 	return string.format("attempt to modify %s", World.Name)
-- end)
return World
