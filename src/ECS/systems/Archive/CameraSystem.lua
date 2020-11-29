-- luacheck: ignore

local CameraSystem = System:new("CameraSystem", {"camera", Camera, Transform}, {"cameraSensor", Camera, Transform})
function CameraSystem:init(...)
	self.idCount = 0
	self.currentCamera = -1
end
function CameraSystem:update(...)
	self.Instance:forEach(self, "animatable", function(entity, components)

	end)
end
function CameraSystem:entityAdded(filer, entity)
	if self.Instance:entityHasComponent(entity, Camera) then
		local components = self.Instance:getEntityComponents(entity)
		local camera = components.Camera
		local transform = components.Transform

		self.idCount = self.idCount + 1
		camera.id = self.idCount
	end
end
function CameraSystem:viewTransform()
	local currentCamera = self.currentCamera
	if currentCamera > 0 then
		local components = self.Instance:getEntityComponents(currentCamera)
		love.graphics.translate(screenSize.x / 2+timer, screenSize.y / 2)
		-- love.graphics.transform(components.Transform.position)
	end
end

return CameraSystem
