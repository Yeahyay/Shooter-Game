-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

World.DefaultWorld:addComponent(Feint.ECS.Component:new("Renderer", {
	{visible = true},
	-- {lastState = {}}
}))

World.DefaultWorld:addComponent(Feint.ECS.Component:new("Transform", {
	{x = 0},
	{y = 0},				-- 1
	{angle = 0},		-- 2
	{sizeX = 32},		-- 3
	{sizeY = 32},		-- 4
	{scaleX = 10},		-- 5
	{scaleY = 10},		-- 6
	{trueSizeX = 0},	-- 7
	{trueSizeY = 0},	-- 8
	-- {sizeX = 50},
	-- {sizeY = 51},
	-- {sizeZ = 52},
	-- {sizeA = 53},
	-- {sizeB = 54},
	-- {sizeC = 55},
	-- {sizeD = 56},
	-- {sizeE = 57},
	-- {sizeF = 58},
	-- {sizeG = 59},
}))

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

local fmath = Feint.Math
local random2 = fmath.random2
function RenderSystem:start()
	-- for k, v in pairs(love.graphics.getSystemLimits()) do
	-- 	print(k, v)
	-- end
	-- print()
	-- for k, v in pairs(love.graphics.getSupported()) do
	-- 	print(k, v)
	-- end

	local world = World.DefaultWorld
	local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
	local archetype = self.EntityManager:newArchetype{Renderer, Transform}
	for i = 1, 20000, 1 do
		self.EntityManager:CreateEntity(archetype)
	end

	self.EntityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
		-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
		-- local x = Data[Transform]
		-- local y = Data[Transform + 1]
		local x = random2(-640, 640)--random2(Feint.Graphics.G_SCREEN_SIZE.x / 2)
		local y = random2(-360, 200)--random2(Feint.Graphics.G_SCREEN_SIZE.y / 2)
		local sizeX = Data[Transform + 3]
		local sizeY = Data[Transform + 4]
		local scaleX = Data[Transform + 5]
		local scaleY = Data[Transform + 6]
		local trueSizeX = scaleX / sizeX
		local trueSizeY = scaleY / sizeY

		Data[Transform] = x
		Data[Transform + 1] = y
		Data[Transform + 7] = trueSizeX
		Data[Transform + 8] = trueSizeY
	end)
end

local input = Feint.Input
local px, py = 0, 0
local lx, ly = 0, 0
function RenderSystem:update(dt)
	do
		lx, ly = px, py
		px, py = input.mouse.Position.x, input.mouse.Position.y
		local angle = Feint.Util.Core.getTime()
		local rect = Feint.Graphics.rectangleInt
		rect(lx, ly, angle, px, py, angle, 1, 1)
		-- local rect = Feint.Graphics.rectangle
		-- rect(px, py, angle, 1, 1)
	end

	local sin, cos, pi = math.sin, math.cos, math.pi
	local rect = Feint.Graphics.rectangle
	for i = 1, 1, 1 do
		local time = Feint.Util.Core.getTime()
		self.EntityManager:forEach("sdads", function(Data, Entity, Renderer, Transform)
			local x = Data[Transform]
			local y = Data[Transform + 1]
			local angle = Data[Transform + 2]
			local trueSizeX = Data[Transform + 7]
			local trueSizeY = Data[Transform + 8]

			rect(x - trueSizeX / 2, y - trueSizeY / 2, angle, trueSizeX, trueSizeY)

			Data[Transform] = x + sin(time * 2 + Entity * 0.1) * 0.5
			Data[Transform + 1] = y + cos(time * 2 + Entity * 0.1) * 0.5
		end)
	end
end

return RenderSystem
