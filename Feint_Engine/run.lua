-- CORE FILE

-- load Feint Engine modules
-- Feint.LoadModule("ECS")
-- Feint.LoadModule("Graphics")
-- Feint.LoadModule("Input")
-- Feint.LoadModule("UI")
-- Feint.LoadModule("Parsing")
-- Feint.LoadModule("Serialize")
-- Feint.LoadModule("Audio")
-- Feint.LoadModule("Tween")

-- It sets up a default world and passes love callbacks to the ECS
local World = Feint.ECS.World

local graphics = Feint.Core.Graphics
-- local oldRate = Feint.Run.rate
function love.keypressed(key, ...)
	if key == "space" then
		if Feint.Run.pause then -- Feint.Run.rate == 0 then
			print("PLAY")
			-- Feint.Run.rate = oldRate
			-- Feint.Run.pause = false
		else
			print("PAUSE")
			-- oldRate = Feint.Run.rate
			-- Feint.Run.rate = 0
			Feint.Run.pause = true
		end
	end
	if key == "q" then
		local world = World.DefaultWorld
		local entityManager = world.EntityManager
		local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
		local archetype = entityManager:getArchetype({Renderer, Transform})
		local entity = entityManager:CreateEntity(archetype)

		entityManager:setComponentData(entity, Transform, {
			{x = Feint.Math.random2(graphics.RenderSize.x / 2)},
			{y = Feint.Math.random2(-graphics.RenderSize.y / 2, graphics.RenderSize.y / 2 - 300)},
											-- 1
			{angle = 0},				-- 2
			{sizeX = 32},				-- 3
			{sizeY = 32},				-- 4
			{scaleX = 10},				-- 5
			{scaleY = 10},				-- 6
			{trueSizeX = 10 / 32},	-- 7
			{trueSizeY = 10 / 32},	-- 8
		})
	end
	if key == "a" then
		print(graphics.ScreenToRenderRatio)
		graphics.RenderSize = graphics.RenderSize % Feint.Math.Vec2.new(0.5, 0.5)
		graphics.RenderToScreenRatio = graphics.ScreenSize / graphics.RenderSize
		graphics.ScreenToRenderRatio = graphics.RenderSize / graphics.ScreenSize
		print(graphics.ScreenToRenderRatio)
	end
	if key == "z" then
		graphics.toggleInterpolation()
	end
end
function love.keyreleased(...)
end

function love.mousemoved(x, y, dx, dy)
	Feint.Input.mousemoved(x, y, dx, dy)
end

function love.mousepressed(...)
end
function love.mousereleased(...)
end

function love.threaderror(thread, message)
	error(string.format("Thread (%s): Error \"%s\"\n", thread, message), 1)
end
function love.load()
	Feint.Run.framerate = 60 -- framerate cap
	Feint.Run.rate = 1 / 60 -- update dt
	Feint.Run.sleep = 0.001

	love.graphics.setLineStyle("rough")
	love.graphics.setDefaultFilter("nearest", "nearest", 16)
	love.math.setRandomSeed(Feint.Math.G_SEED)

	Feint.Paths.Add("Game_ECS_Files", "src.ECS")
	Feint.Paths.Add("Game_ECS_Bootstrap", Feint.Paths.Game_ECS_Files.."bootstrap", "file")
	Feint.Paths.Add("Game_ECS_Components", Feint.Paths.Game_ECS_Files.."components")
	Feint.Paths.Add("Game_ECS_Systems", Feint.Paths.Game_ECS_Files.."systems")
	local systems = {} -- luacheck: ignore
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

	Feint.Log.log("\n%s update order:\n", World.DefaultWorld.Name)
	World.DefaultWorld:generateUpdateOrderList()
	for k, v in ipairs(World.DefaultWorld.updateOrder) do
		Feint.Log.log("%d: %s\n", k, World.DefaultWorld.systems[k].Name)
	end
	Feint.Log.logln()

	World.DefaultWorld:start()

	-- luacheck: ignore
	if false then
		love.window.updateMode(960, 540, {
			fullscreen = false,
			fullscreentype = "desktop",
			vsync = false,
			msaa = 0,
			resizable = false,
			borderless = false,
			centered = true,
			display = 1,
			minwidth = 1,
			minheight = 1,
			highdpi = false,
			x = nil,
			y = nil,
		})
	end

	-- [[
	for i = 1, 1, 1 do
		Feint.Thread.newWorker(i, nil)
	end
	love.timer.sleep(0.1)
	for i = 1, 1, 1 do
		Feint.Log.logln("STARTING THREAD %d", i)
		Feint.Thread.startWorker(i)

		local threadData = {
			go = true,
			-- func = string.dump(function(test)
			-- 	print("yo", test)
			-- end),
			func = string.dump(function(test)
				while true do
					local a = 0
					local b = {}
					for i = 10000, 1, -1 do
						local a = i + 1
						b[i] = a
					end
					print("sadkmnk")
					-- sort(b)
					sleep(0.0001)
				end
			end),
			type = "string",
		}

		local channel = love.thread.getChannel("thread_data_"..i)

		channel:push(threadData)

		Feint.Log.logln("WAITING FOR THREAD %d", i)
		local wait = false
		wait = channel:demand()
		-- while not wait and wait ~= threadData do
			Feint.Log.logln("RECIEVED", wait)
		-- end
		Feint.Log.logln("DONE WAITING FOR THREAD %d", i)

	end
	--]]

	Feint.UI.Immediate.Initialize()
end

Feint.Util.Debug.PRINT_ENV(_G, false)


-- local avg = 0
-- local avgTimes = 0
local getTime = love.timer.getTime

local run = Feint.Core.Run
local lgraphics = love.graphics
function love.update(dt)
	graphics.clear()

		graphics.RenderSize = Feint.Math.Vec2.new(1280, 720)
		-- graphics.RenderSize = graphics.RenderSize * ((0.5 + math.sin(Feint.Util.Core.getTime()) * 0.5) * 0.1 + 0.9)
		graphics.RenderToScreenRatio = graphics.ScreenSize / graphics.RenderSize
		graphics.ScreenToRenderRatio = graphics.RenderSize / graphics.ScreenSize

	local startTime = getTime()

	if true then
		World.DefaultWorld:update(dt) -- luacheck: ignore
	end

	graphics.processAddQueue()	-- process all pending draw queue insertions
	graphics.processQueue()		-- process all draw data updates

	if Feint.UI.Immediate then
		Feint.UI.Immediate.Update(dt)
	end

	local endTime = getTime()

	run.G_UPDATE_DT = endTime - startTime

	run.G_UPDATE_TIME = run.G_UPDATE_TIME + (run.G_UPDATE_DT - run.G_UPDATE_TIME) * (1 - run.G_UPDATE_TIME_SMOOTHNESS)

	run.G_UPDATE_TIME_PERCENT_FRAME = run.G_UPDATE_TIME / (run.rate) * 100

	Feint.UI.Immediate.Update(run.G_RENDER_DT)

end

local function updateRender(dt) -- luacheck: ignore
end

local DEFAULT_FONT = love.graphics.newFont("Assets/fonts/FiraCode-Regular.ttf", 28)
local DEFAULT_FONT_HEIGHT = DEFAULT_FONT:getHeight()
love.graphics.setFont(DEFAULT_FONT)

local	fpsList = {}
for i = 1, run.G_AVG_FPS_DELTA_ITERATIONS, 1 do
	fpsList[i] = 0
end
local fpsIndex = 1
local fpsSum = 0

local canvas = love.graphics.newCanvas(graphics.RenderSize.x, graphics.RenderSize.y, {msaa = 0})
-- local debug = love.graphics.newCanvas(graphics.RenderSize.x, graphics.RenderSize.y, {msaa = 0})

-- local acc = 0
function love.draw(dt)
	do
		run.G_FPS_DELTA = run.G_FPS_DELTA + (run.dt - run.G_FPS_DELTA) * (1 - run.G_FPS_DELTA_SMOOTHNESS)
		run.G_FPS = 1 / run.G_FPS_DELTA
	end

	do
		fpsSum = fpsSum -	fpsList[fpsIndex] + run.dt
		fpsList[fpsIndex] = run.dt
		fpsIndex = fpsIndex % run.G_AVG_FPS_DELTA_ITERATIONS + 1
		run.G_AVG_FPS_DELTA = fpsSum / run.G_AVG_FPS_DELTA_ITERATIONS

		run.G_AVG_FPS = 1 / run.G_AVG_FPS_DELTA
	end

	run.G_INT = run.accum / math.max(0, run.rate)

	local startTime = getTime()

	lgraphics.setCanvas(canvas)
	lgraphics.clear()
	lgraphics.push()
		lgraphics.translate(graphics.RenderSize.x / 2, -graphics.RenderSize.y / 2)
		-- lgraphics.setWireframe(true)
		graphics.updateInterpolate(run.accum)
		-- graphics.processQueue()
		graphics.draw()
		-- lgraphics.setWireframe(false)
	lgraphics.pop()
	lgraphics.setCanvas()
	lgraphics.draw(canvas, 0, 0, 0, graphics.RenderToScreenRatio.x, graphics.RenderToScreenRatio.y, 0, 0)

	Feint.UI.Immediate.Draw(run.G_RENDER_DT)

	local endTime = getTime()

	run.G_RENDER_DT = endTime - startTime

	run.G_RENDER_TIME = run.G_RENDER_TIME + (run.G_RENDER_DT - run.G_RENDER_TIME) * (1 - run.G_RENDER_TIME_SMOOTHNESS)

	run.G_RENDER_TIME_PERCENT_FRAME = run.G_RENDER_TIME / (run.rate) * 100

	--[[
	local f = 60
	acc = acc + run.G_RENDER_DT * f
	while acc > 1 / 60 do
		updateRender(acc)
		acc = acc - 1 / 60
	end
	--]]

	-- FPS
	lgraphics.printf(
		string.format("FPS:      %7.2f, DT:      %7.4fms\n",
		run.G_FPS, 1000 * run.G_FPS_DELTA), 0, 0, graphics.ScreenSize.x, "left", 0, 0.5, 0.5)
	-- [[
	lgraphics.printf(
		string.format("FPS AVG:  %7.2f, DT AVG:  %7.4fms\n", run.G_AVG_FPS, 1000 * run.G_AVG_FPS_DELTA),
		0, DEFAULT_FONT_HEIGHT / 2, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(
		string.format("FPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / run.dt, 1000 * run.dt),
		0, DEFAULT_FONT_HEIGHT / 2 * 2, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- UPDATE TIME
	lgraphics.printf(
		string.format("UPDATE:     %8.4fms, %6.2f%% 60Hz\n", 1000 * run.G_UPDATE_TIME, run.G_UPDATE_TIME_PERCENT_FRAME),
		0, DEFAULT_FONT_HEIGHT / 2 * 4, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(
		string.format("UPDATE AVG: %8.4fms, %6.2f%% 60Hz\n", 0, 0),
		0, DEFAULT_FONT_HEIGHT / 2 * 5, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(
		string.format("UPDATE TRUE:%8.4fms, %6.2f%% 60Hz\n", 1000 * run.G_UPDATE_DT, run.G_UPDATE_DT / (run.rate) * 100),
		0, DEFAULT_FONT_HEIGHT / 2 * 6, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	-- RENDER TIME
	lgraphics.printf(
		string.format("RENDER:     %8.4fms, %6.2f%% Frame\n", 1000 * run.G_RENDER_TIME, run.G_RENDER_TIME_PERCENT_FRAME),
		350, DEFAULT_FONT_HEIGHT / 2 * 4, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(
		string.format("RENDER AVG: %8.4fms, %6.2f%% Frame\n", 0, 0),
		350, DEFAULT_FONT_HEIGHT / 2 * 5, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(
		string.format("RENDER TRUE:%8.4fms, %6.2f%% Frame\n", 1000 * run.G_RENDER_DT, run.G_RENDER_DT / (run.rate) * 100),
		350, DEFAULT_FONT_HEIGHT / 2 * 6, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)


	-- lgraphics.printf(
	-- 	string.format("TPS:      %7.2f, DT:      %7.4fms\n", run.G_TPS, 1000 * run.G_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 4, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- lgraphics.printf(
	-- 	string.format("TPS AVG:  %7.2f, DT AVG:  %7.4fms\n", run.G_AVG_TPS, 1000 * run.G_AVG_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 5, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- lgraphics.printf(
	-- 	string.format("TPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / run.rate, 1000 * run.rate),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 6, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )

	-- MEMORY
	lgraphics.printf(string.format("Memory Usage (MiB):   %12.2f", Feint.Util.Core.getMemoryUsageKiB() / 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 8, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(string.format("Memory Usage (KiB):   %12.2f", Feint.Util.Core.getMemoryUsageKiB()),
		0, DEFAULT_FONT_HEIGHT / 2 * 9, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(string.format("Memory Usage (bytes): %12.2f", Feint.Util.Core.getMemoryUsageKiB() * 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 10, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- DRAWING
	local stats = lgraphics.getStats()
	lgraphics.printf(string.format("Draw calls: %d", stats.drawcalls),
		0, DEFAULT_FONT_HEIGHT / 2 * 12, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	lgraphics.printf(string.format("Texture Memory: %d bytes", stats.texturememory),
		0, DEFAULT_FONT_HEIGHT / 2 * 13, graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	--]]
end
function love.quit()
end

-- PRINT_ENV(_ENV, false)

printf("\n")
Feint.Log.log("Exiting run.lua\n")
