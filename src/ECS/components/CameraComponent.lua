local Component = Feint.ECS.Component
local Camera = Feint.ECS.Component:new("Camera", {
	id = -1;
	zoom = 1;
	currentZoom = 1;
	target = Component.ENTITY;
})

return Camera
