local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System

local Renderer = Feint.ECS.Component:new("Renderer", {
	test = 0
});

local Transform = Feint.ECS.Component:new("Transform", {
	test = 0
});

local Entity = {Name = "Entity"}

local RenderSystem = System:new("RenderSystem")
function RenderSystem:init(...)
end
-- Feint.Util.Memoize(
local components = {Entity, Renderer, Transform}--{Entity, Transform, Renderer, Physics}
function RenderSystem:update(...)
	-- local instance = Renderer:new{}

	self.EntityManager:forEach(self, components, function(entity, transform, renderer, physics)
	-- 	-- local transform = components.Transform
	-- 	-- local renderer = components.Renderer
	-- 	-- local physics = components.Physics
	--
	end)

	-- Feint.Log.log(""\n\n")
	printf("\n")

	-- self.EntityManager:forEach(self, {Entity, Transform, Renderer, Physics}, function(entity, transform, renderer, physics)
	-- 	local transform = components.Transform
	-- 	local renderer = components.Renderer
	-- 	local physics = components.Physics
	-- end)
end

return RenderSystem
