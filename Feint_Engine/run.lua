-- CORE FILE
local World = Feint.ECS.World

function love.keypressed(...)
end
function love.keyreleased(...)
end

function love.mousemoved(...)
end

function love.mousepressed(...)
end
function love.mousereleased(...)
end

function love.load()
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem1"))
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem2"))
	-- World.DefaultWorld:generateUpdateOrderList()

	Feint.Paths.Add("Game_ECS_Files", "src.ECS", "external")
	Feint.Paths.Add("Game_ECS_Bootstrap", Feint.Paths.Game_ECS_Files.."bootstrap", "external", "file")
	Feint.Paths.Add("Game_ECS_Components", Feint.Paths.Game_ECS_Files.."components", "external")
	Feint.Paths.Add("Game_ECS_Systems", Feint.Paths.Game_ECS_Files.."systems", "external")
	local systems = {}
	local systemCount = 0
	for k, v in pairs(love.filesystem.getDirectoryItems(Feint.Paths.SlashDelimited(Feint.Paths.Game_ECS_Systems))) do
		-- print(k, v)
		if v:match(".lua") then
			local path = Feint.Paths.Game_ECS_Systems..v:gsub(".lua", "")
			local system = require(path)
			systemCount = systemCount + 1
			systems[systemCount] = system
			World.DefaultWorld:registerSystem(system)
		end
	end

	World.DefaultWorld:generateUpdateOrderList()
	for k, v in ipairs(World.DefaultWorld.updateOrder) do
		printf("%d: %s\n", k, World.DefaultWorld.systems[k].Name)
	end

	Feint.Log.log();
end

Feint.Util.Debug.PRINT_ENV(_G, false)

local startTime = love.timer.getTime()
function love.update(dt)
	G_TIMER = Feint.Math.round(love.timer.getTime() - startTime, 10)--G_TIMER + tick.dt
	if true then
		World.DefaultWorld:update()
	end
	-- if currentGame then
	-- 	currentGame.update(dt)
	-- 	if Slab then
	-- 		Slab.Update(dt)
	-- 	end
	-- 	if currentGame.gui then
	-- 		currentGame.gui()
	-- 	end
	-- end
end
function love.draw(dt)
	G_FPS = 1 / tick.dt
	G_INT = tick.accum / math.max(0, tick.rate)
	if currentGame then
		currentGame.draw(dt)
		if Slab then
			Slab.Draw(dt)
		end
	end
end
function love.quit()
	if currentGame then
		currentGame.quit()
	end
end

-- PRINT_ENV(_ENV, false)

printf("\nExiting run.lua\n")
