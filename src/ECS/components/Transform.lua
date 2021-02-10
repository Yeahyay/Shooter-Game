local Transform

if Feint.ECS.FFI_OPTIMIZATIONS then
	Transform = Feint.ECS.Component:new("Transform", {
		x = 100,						-- 0
		y = 0,						-- 1
		angle = 0,					-- 2
		sizeX = 32,					-- 3
		sizeY = 32,					-- 4
		scaleX = 32,				-- 5
		scaleY = 32,				-- 6
		trueSizeX = 32 / 32,		-- 7
		trueSizeY = 32 / 32,		-- 8
	})
else
	Transform = Feint.ECS.Component:new("Transform", {
		{x = 0},						-- 0
		{y = 0},						-- 1
		{angle = 0},				-- 2
		{sizeX = 32},				-- 3
		{sizeY = 32},				-- 4
		{scaleX = 16},				-- 5
		{scaleY = 16},				-- 6
		{trueSizeX = 16 / 32},	-- 7
		{trueSizeY = 16 / 32},	-- 8
	})
end

return Transform
