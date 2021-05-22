local Component = Feint.ECS.Component
local Physics = Component:new("Physics", {
	posXOld = 0;
	posYOld = 0;
	velX = 0;
	velY = 0;
	accX = 0;
	accY = 0;
	drag = 0.2;
	accCapX = math.huge;
	accCapY = math.huge;
})

return Physics
