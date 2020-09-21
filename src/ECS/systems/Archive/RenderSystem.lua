local RenderSystem = System:new("RenderSystem",
	{"physics", Renderer, Physics, Transform},
	{"renderable", Renderer, Transform}
)
function RenderSystem:init(...)
end
function RenderSystem:update(...)
	-- self.Instance:forEach(self, "renderable", function(entity, components)
	--
	-- end)
end
function RenderSystem:entityAdded(filter, entity)
end
function RenderSystem:draw(...)
	local size = self.Instance:forEach(self, "renderable", function(entity, components)
		local transform = components.Transform
		local renderer = components.Renderer
		local physics = components.Physics

		local position = vMath:vec3ToVec2(transform.position)
		local angle = transform.angle
		local size = vMath:vec3ToVec2(transform.size)

		love.graphics.push()

		love.graphics.translate(position.x, - position.y)
		love.graphics.rotate(angle)
		love.graphics.rectangle("line", - size.x / 2, - size.y / 2, size.x, size.y)

		love.graphics.pop()
	end)
	self.Instance:forEach(self, "physics", function(entity, components)
		local transform = components.Transform
		local renderer = components.Renderer
		local physics = components.Physics

		local position = vMath:vec3ToVec2(transform.position)
		local angle = transform.angle
		local size = vMath:vec3ToVec2(transform.size)

		love.graphics.push()

		love.graphics.translate(position.x, - position.y)
		love.graphics.rotate(angle)
		-- love.graphics.rectangle("line", - size.x / 2, - size.y / 2, size.x, size.y)
		-- local size = size/2
		-- love.graphics.rectangle("line", - size.x / 2, - size.y / 2, size.x, size.y)

		love.graphics.pop()
	end)
end

return RenderSystem
