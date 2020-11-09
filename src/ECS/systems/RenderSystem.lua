-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	{visible = true},
	-- {lastState = {}}
});

local Transform = Feint.ECS.Component:new("Transform", {
	{x = 0},
	{y = 0},
	{sizeX = 10},
	{sizeY = 10},
	{angle = 0},
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

local _archetype = {Renderer, Transform}

local math = Feint.Math
local random2 = math.random2

local components = {Entity, unpack(_archetype)}--{Entity, Transform, Renderer, Physics}
function RenderSystem:start()
	local archetype = self.EntityManager:newArchetype(_archetype)
	for i = 1, 2000, 1 do
		self.EntityManager:CreateEntity(archetype)
	end
	self.EntityManager:forEach(self, components, function(data, entity, renderer, transform, physics)
		-- Feint.Log.log("entity %02d: transform[x: %0.4f, y: %0.4f]\n", entity, data[transform], data[transform + 1])
		-- local x = data[transform]
		-- local y = data[transform + 1]
		local x = random2(Feint.Graphics.G_SCREEN_SIZE.x / 2)
		local y = random2(Feint.Graphics.G_SCREEN_SIZE.y / 2)
		local angle = random2(math.pi)

		data[transform] = x
		data[transform + 1] = y
		data[transform + 4] = y

		-- for k, v in pairs(data) do print(k, v) if k >= 10 then break end end
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
		px, py = input.mouse.Position.x - 50 / 2, input.mouse.Position.y + 50 / 2
		local rect = Feint.Graphics.rectangle
		rect(lx, ly, 0, "fill", px, py, 50, 50)
	end

	self.EntityManager:forEach(self, components, function(data, entity, renderer, transform, physics)
		local x = data[transform]
		local y = data[transform + 1]
		local sizeX = data[transform + 2]
		local sizeY = data[transform + 3]
		-- print(data[transform], data[transform + 1], data[transform + 2], data[transform + 3])
		-- print("", entity, "r: "..renderer, "t: "..transform)

		local rect = Feint.Graphics.rectangle
		rect(x - sizeX / 2, y - sizeY / 2, 0, "fill", x - sizeX / 2, y - sizeY / 2, sizeX, sizeY)

		-- data[transform] = x
		-- data[transform + 1] = y
		-- Feint.Log.log("entity %02d: transform[x: %0.4f, y: %0.4f]\n", entity, data[transform], data[transform + 1])
	end)

	-- Feint.Log.log(""\n\n")
	-- printf("\n")
end

return RenderSystem
