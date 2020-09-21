local Physics = Component:new("Physics", function(self)
	-- self.velocity = vMath.Vec3(0, 0, 0)
	self.world = false
	self.sensor = false
	self.type = "dynamic"
	self.body = false
	self.shape = false
	self.fixture = false
	self.preSolve = function() end
	self.postSolve = function() end
end)
return Physics
