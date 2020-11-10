-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	{visible = true},
	-- {lastState = {}}
});

local Transform = Feint.ECS.Component:new("Transform", {
	{x = 0},
	{y = 0},
	{sizeX = 1},
	{sizeY = 1},
	{angle = 0},
	{direction = 0},
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
});

local Entity = {Name = "Entity"}

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

local fmath = Feint.Math
local random2 = fmath.random2
function RenderSystem:start()
	self.World:addComponent(Renderer)
	self.World:addComponent(Transform)
	-- for k, v in pairs(love.graphics.getSystemLimits()) do
	-- 	print(k, v)
	-- end
	-- print()
	-- for k, v in pairs(love.graphics.getSupported()) do
	-- 	print(k, v)
	-- end
	local archetype = self.EntityManager:newArchetype{Renderer, Transform}
	for i = 1, 1500, 1 do
		self.EntityManager:CreateEntity(archetype)
	end
	local t = 0
	self.EntityManager:forEach("ri", {"Data", "Entity", Renderer, Transform}, function(Data, Entity, Renderer, Transform)
		-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
		-- local x = Data[Transform]
		-- local y = Data[Transform + 1]
		t = t + 1
		local x = random2(-640, 640)--random2(Feint.Graphics.G_SCREEN_SIZE.x / 2)
		local y = random2(-360, 200)--random2(Feint.Graphics.G_SCREEN_SIZE.y / 2)
		-- print(x, y)
		-- local angle = random2(math.pi)

		Data[Transform] = x
		Data[Transform + 1] = y
		Data[Transform + 5] = (math.mod(Entity, 2)) * 2 - 1
		-- Data[Transform + 4] = angle

		-- for k, v in pairs(Data) do print(k, v) if k >= 10 then break end end
	end)

end

local input = Feint.Input
local px, py = 0, 0
local lx, ly = 0, 0
-- Feint.Util.Memoize(
function RenderSystem:update(dt)
	-- local instance = Renderer:new{}
	do
		lx, ly = px, py
		px, py = input.mouse.Position.x, input.mouse.Position.y
		local angle = Feint.Util.Core.getTime()
		-- local rect = Feint.Graphics.rectangleInt
		-- rect(lx, ly, angle, px, py, angle, 50, 50)
		local rect = Feint.Graphics.rectangle
		rect(px, py, angle, 1, 1)
	end

	-- self.EntityManager:forEach(self, )

	for i = 1, 10, 1 do
		self.EntityManager:forEach("sdads", {"Data", "Entity", Renderer, Transform}, function(Data, Entity, Renderer, Transform)
			local x = Data[Transform]
			local y = Data[Transform + 1]
			local sizeX = Data[Transform + 2]
			local sizeY = Data[Transform + 3]
			local angle = Data[Transform + 4]
			local direction = Data[Transform + 5]

			-- print(Data[Transform], Data[Transform + 1], Data[Transform + 2], Data[Transform + 3])
			-- print("", Entity, "r: "..renderer, "t: "..Transform)

			local rect = Feint.Graphics.rectangle
			rect(x - sizeX / 2, y - sizeY / 2, angle, sizeX, sizeY)

			Data[Transform + 4] = angle + math.pi / 60 * direction
			local time = Feint.Util.Core.getTime()
			Data[Transform] = x + math.sin(time * 2 + Entity) / 2
			Data[Transform + 1] = y + math.cos(time * 2 + Entity) / 2
			-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
		end)
	end

	-- Feint.Log.log(""\n\n")
	-- printf("\n")
end

return RenderSystem
