-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	{visible = true},
	-- {lastState = {}}
});

local Transform = Feint.ECS.Component:new("Transform", {
	{x = 0},
	{y = 0},
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
	for i = 1, 8000, 1 do
		self.EntityManager:CreateEntity(archetype)
	end
	self.EntityManager:forEach(self, components, function(data, entity, renderer, transform, physics)
		local x = data[transform]
		local y = data[transform + 1]
		x = random2(-200, 200)
		y = random2(-200, 200)

		data[transform] = x
		data[transform + 1] = y
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
		-- each argument is the index offset for the start of each component
		-- every component object has a table for each component field's index offset
		-- local transform = components.Transform
		-- local renderer = components.Renderer
		-- local physics = components.Physics
		-- Feint.Log.logln(data[transform])
		-- Feint.Log.log("%s %s %s\n", data[renderer], data[renderer + 1], data[transform])
		local x = data[transform]
		local y = data[transform + 1]

		local rect = Feint.Graphics.rectangle
		rect(x, y, 0, "fill", x, y, 50, 50)

		-- data[transform] = x
		-- data[transform + 1] = y
		-- Feint.Log.log("entity %02d: transform[x: %0.4f, y: %0.4f]\n", entity, data[transform], data[transform + 1])
	end)

	-- Feint.Log.log(""\n\n")
	-- printf("\n")
end

return RenderSystem
