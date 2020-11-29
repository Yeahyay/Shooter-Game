-- luacheck: ignore

local Transform = Component:new("Transform", function(self)
	self.position = vMath.Vec3(-100, - 100, - 100)
	self.size = vMath.Vec3(10, 10, 10)
	self.angle = 0
end)
return Transform
