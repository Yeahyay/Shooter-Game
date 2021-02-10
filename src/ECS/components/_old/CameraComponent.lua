-- luacheck: ignore

local Camera = Component:new("Camera", function(self)
	self.id = -1
	self.zoom = 1
	self.currentZoom = 1
end)
return Camera
