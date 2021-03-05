local Renderer

if Feint.ECS.FFI_OPTIMIZATIONS then
	Renderer = Feint.ECS.Component:new("Renderer", {
		visible = true;
		texture = "Test Texture 1.png";
		id = -1;
	})
else
	Renderer = Feint.ECS.Component:new("Renderer", {
		{visible = true};
	})
end

return Renderer
