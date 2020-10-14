-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	visible = true,
	lastState = {}
});

local Transform = Feint.ECS.Component:new("Transform", {
	x = 0,
	y = 0,
	sizeX = 50,
	sizeY = 51,
	sizeZ = 52,
	sizeA = 53,
	sizeB = 54,
	sizeC = 55,
	sizeD = 56,
	sizeE = 57,
	sizeF = 58,
	sizeG = 59,
});

local Entity = {Name = "Entity"}

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end

function RenderSystem:start()
	local archetype = self.EntityManager:newArchetype({Renderer, Transform})
	self.EntityManager:CreateEntity(archetype)
end

-- Feint.Util.Memoize(
local components = {Entity, Renderer, Transform}--{Entity, Transform, Renderer, Physics}
function RenderSystem:update(dt)
	-- local instance = Renderer:new{}

	self.EntityManager:forEach(self, components, function(entity, transform, renderer, physics)
	-- 	-- local transform = components.Transform
	-- 	-- local renderer = components.Renderer
	-- 	-- local physics = components.Physics
		Feint.Log.log("Yeet\n")
	end)

	-- Feint.Log.log(""\n\n")
	-- printf("\n")
end

return RenderSystem
