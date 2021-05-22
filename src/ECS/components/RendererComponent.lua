local Component = Feint.ECS.Component
local Renderer = Component:new("Renderer", {
	visible = true;
	texture = "Test Texture 1.png";
	id = -1;
})

return Renderer
