local Component = Feint.ECS.Component
local Transform = Component:new("Transform", {
	x = 0,						-- 0
	y = 0,						-- 1
	angle = 0,					-- 2
	sizeX = 32,					-- 3
	sizeY = 32,					-- 4
	scaleX = 32,				-- 5
	scaleY = 32,				-- 6
	trueSizeX = 32 / 32,		-- 7
	trueSizeY = 32 / 32,		-- 8
})

return Transform
