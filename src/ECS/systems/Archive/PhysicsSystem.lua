-- luacheck: ignore

local PhysicsSystem = System:new("PhysicsSystem", {"generic", Physics, Transform})
function PhysicsSystem:init(world)
	self.physicsTimes = 1
	self.world = world
	local function preSolve(fixture1, fixture2, contact)
		local components1 = self.Instance:getEntityComponents(fixture1:getUserData())
		local components2 = self.Instance:getEntityComponents(fixture2:getUserData())
		local physics1, physics2 = components1.Physics, components2.Physics

		if physics1.preSolve then
			physics1.preSolve(physics1, physics2, contact)
		end
		if physics2.preSolve then
			physics2.preSolve(physics2, physics1, contact)
		end
	end
	local function postSolve(fixture1, fixture2, contact, nImpulse1, tImpulse1, nImpulse2, tImpulse2)
		local components1 = self.Instance:getEntityComponents(fixture1:getUserData())
		local components2 = self.Instance:getEntityComponents(fixture2:getUserData())
		local physics1, physics2 = components1.Physics, components2.Physics

		local transform1, transform2 = components1.Transform, components2.Transform
		local position1, position2 = transform1.position, transform2.position

		-- local string = ("%4.2f %4.2f"):format(nImpulse1, math.deg(tImpulse1))

		-- love.graphics.push()
		-- love.graphics.translate(screenSize.x/2, screenSize.y/2)
		-- love.graphics.line(position1.x, -position1.z, position2.x, -position2.z)
		-- love.graphics.print(string, position1.x, -position1.z, 0, 1, 1)
		-- love.graphics.pop()

		if physics1.postSolve then
			physics1.postSolve(physics1, physics2, contact, nImpulse1, tImpulse1, nImpulse2, tImpulse2)
		end
		if physics2.postSolve then
			physics2.postSolve(physics2, physics1, contact, nImpulse1, tImpulse1, nImpulse2, tImpulse2)
		end
	end
	self.world:setCallbacks(onEnter, onLeave, preSolve, nil)--postSolve)
	-- print(world, self.world, PhysicsSystem.world)
end
function PhysicsSystem:update(dt)
	self.world:update(dt, 8*self.physicsTimes, 3*self.physicsTimes)
	self.Instance:forEach(self, "generic", function(entity, chunk)
		local physics = chunk:getComponent(entity, Physics)
		local transform = chunk:getComponent(entity, Transform)
		local body = physics.body
		local x, y = body:getPosition()
		transform.position = vMath.Vec3.new(x, 0, - y)
		transform.angle = body:getAngle()
	end)
end
function PhysicsSystem:setPhysicsData(entity, data, method, ...)
	if self.Instance:entityHasComponent(entity, Physics) then
		local components = self.Instance:getEntityComponents(entity)
		local physics = components.Physics

		local object = physics[data]
		object[method](object, ...)
	end
end
function PhysicsSystem:entityAdded(filter, entity)
	self.Instance:setComponentData(entity, Physics, function(component)
		local position = vMath.Vec3(0, 0, 0)
		local size = vMath.Vec3(1, 0, 1)

		local components = self.Instance:getEntityComponents(entity)

		if self.Instance:entityHasComponent(entity, Transform) then
			local transform = components.Transform

			local position = transform.position
			local size = transform.size

			if self.Instance:entityHasComponent(entity, Physics) then
				local physics = components.Physics

				component.world = self.world
				component.body = love.physics.newBody(self.world, position.x, - position.z, component.type or "dynamic")
				component.shape = love.physics.newRectangleShape(size.x, size.z)
				component.fixture = love.physics.newFixture(component.body, component.shape, 10)
				component.fixture:setUserData(entity)
				component.fixture:setSensor(physics.sensor)
			end
		end
	end)
end

return PhysicsSystem
