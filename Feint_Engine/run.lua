-- CORE FILE
-- It sets up a default world and passes love callbacks to the ECS
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

function love.threaderror(thread, message)
	error(string.format("Thread (%s): Error \"%s\"\n", thread, message))
end
function love.load()
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem1"))
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem2"))
	-- World.DefaultWorld:generateUpdateOrderList()


	Feint.Paths.Add("Game_ECS_Files", "src.ECS")
	Feint.Paths.Add("Game_ECS_Bootstrap", Feint.Paths.Game_ECS_Files.."bootstrap", "file")
	Feint.Paths.Add("Game_ECS_Components", Feint.Paths.Game_ECS_Files.."components")
	Feint.Paths.Add("Game_ECS_Systems", Feint.Paths.Game_ECS_Files.."systems")
	local systems = {}
	local systemCount = 0
	for k, v in pairs(love.filesystem.getDirectoryItems(Feint.Paths.SlashDelimited(Feint.Paths.Game_ECS_Systems))) do
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
		log("%d: %s\n", k, World.DefaultWorld.systems[k].Name)
	end

	--[[
	-- Feint.Log.log();
	Feint.Thread.newWorker(1, function(self)

	end)
	Feint.Thread.startWorker(1)
	local channel = love.thread.getChannel("thread_data_"..Feint.Thread.getWorkers()[1].id)
	channel:push("local x = 1; return x")
	--]]
end

Feint.Util.Debug.PRINT_ENV(_G, false)

local run = Feint.Run

local startTime = love.timer.getTime()
function love.update(dt)
	-- G_TIMER = Feint.Math.round(love.timer.getTime() - startTime, 10)--G_TIMER + tick.dt
	if false then
		World.DefaultWorld:update()
	end
	local a = 0
	for i = 1, 6300000, 1 do
		a = a + i
	end
	-- love.timer.sleep(1/345)
	--[[
	if currentGame then
		currentGame.update(dt)
		if Slab then
			Slab.Update(dt)
		end
		if currentGame.gui then
			currentGame.gui()
		end
	end
	--]]

	-- print(run.dt)
end

-- Feint.Run.framerate = 10

local dtList = {}
for i = 1, G_AVG_DELTA_ITERATIONS, 1 do
	dtList[i] = 0
end
local dtIndex = 1

local ui = Feint.UI.Immediate
ui.Initialize()
function love.draw(dt)
	G_FPS = 1 / run.dt

	-- G_AVG_DELTA = G_AVG_DELTA - dtList[dtIndex]
	-- G_AVG_DELTA = G_AVG_DELTA + run.dt
	-- dtList[dtIndex] = run.dt
	-- -- dtIndex = (dtIndex + 1) % G_AVG_DELTA_ITERATIONS
	-- dtIndex = dtIndex + 1
	-- if dtIndex == G_AVG_DELTA_ITERATIONS + 1 then
	-- 	dtIndex = 1
	-- end
	-- G_AVG_FPS = 1 / G_AVG_DELTA

	-- last = G_AVG_FPS

	local smoothing = 1 - 0.01
	G_AVG_FPS = (G_AVG_FPS * smoothing) + ((1 / run.dt) * (1.0-smoothing))

	-- if run.frames > 10 then
	-- 	G_AVG_DELTA = G_AVG_DELTA
	G_INT = run.accum / math.max(0, run.rate)
	-- if currentGame then
	-- 	currentGame.draw(dt)
	-- 	if Slab then
	-- 		Slab.Draw(dt)
	-- 	end
	-- end
	-- love.graphics.rectangle("fill", 200, 200, 200, 200)
	-- love.graphics.print("FPS: " .. G_FPS, 0, 0, G_SCREEN_SIZE.x, "left", 0)
	-- love.graphics.print("FPS: " .. G_FPS, 0, 0, 0, 1, 1)
	love.graphics.printf({{1, 1, 1, 1}, "FPS: " .. G_AVG_FPS .. ", DT: " .. G_AVG_DELTA}, 0, 0, G_SCREEN_SIZE.x, "left", 0, 1, 1)
end
function love.quit()
	if currentGame then
		currentGame.quit()
	end
end

-- PRINT_ENV(_ENV, false)

printf("\n")
log("Exiting run.lua\n")
