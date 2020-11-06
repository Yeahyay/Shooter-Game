-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	{visible = true},
	{lastState = {}}
});

local Transform = Feint.ECS.Component:new("Transform", {
	{x = 0},
	{y = 0},
	{sizeX = 50},
	{sizeY = 51},
	{sizeZ = 52},
	{sizeA = 53},
	{sizeB = 54},
	{sizeC = 55},
	{sizeD = 56},
	{sizeE = 57},
	{sizeF = 58},
	{sizeG = 59},
});

local Entity = {Name = "Entity"}

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

local _archetype = {Renderer, Transform}

function RenderSystem:start()
	local archetype = self.EntityManager:newArchetype(_archetype)
	for i = 1, 1000, 1 do
		self.EntityManager:CreateEntity(archetype)
	end
end

local input = Feint.Input
local px, py = 0, 0
local lx, ly = 0, 0
-- Feint.Util.Memoize(
local components = {Entity, unpack(_archetype)}--{Entity, Transform, Renderer, Physics}
function RenderSystem:update(dt)
	-- local instance = Renderer:new{}
	do
		lx, ly = px, py
		px, py = input.mouse.PositionRaw.x - 50 / 2, input.mouse.PositionRaw.y + 50 / 2
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
		data[transform] = data[transform] + Feint.Math.random2(-2, 2)
		data[transform + 1] = data[transform + 1] + Feint.Math.random2(-2, 2)
		-- Feint.Log.log("entity %02d: transform[x: %0.4f, y: %0.4f]\n", entity, data[transform], data[transform + 1])
	end)

	-- Feint.Log.log(""\n\n")
	-- printf("\n")
end

return RenderSystem
