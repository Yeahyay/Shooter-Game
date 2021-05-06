local Physics

Physics = Feint.ECS.Component:new("Physics", {
	positionXOld = 0;
	positionYOld = 0;
	velocityX = 0;
	velocityY = 0;
	accelerationX = 0;
	accelerationY = 0;
	drag = 0.2;
	accelerationCapX = math.huge;
	accelerationCapY = math.huge;
})

return Physics
