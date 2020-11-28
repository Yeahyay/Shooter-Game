-- CORE FILE
-- It sets up a default world and passes love callbacks to the ECS
local World = Feint.ECS.World

local oldRate = Feint.Run.rate
function love.keypressed(key, ...)
	if key == "space" then
		if Feint.Run.rate == 0 then
			print("PLAY")
			Feint.Run.rate = oldRate
		else
			print("PAUSE")
			oldRate = Feint.Run.rate
			Feint.Run.rate = 0
		end
	end
	if key == "q" then
		local world = World.DefaultWorld
		local entityManager = world.EntityManager
		local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
		local archetype = entityManager:getArchetype({Renderer, Transform})
		local entity = entityManager:CreateEntity(archetype)

		entityManager:setComponentData(entity, {
			{x = Feint.Math.random2(Feint.Graphics.RenderSize.x / 2)},
			{y = Feint.Math.random2(-Feint.Graphics.RenderSize.y / 2, Feint.Graphics.RenderSize.y / 2 - 300)},
											-- 1
			{angle = 0},				-- 2
			{sizeX = 32},				-- 3
			{sizeY = 32},				-- 4
			{scaleX = 10},				-- 5
			{scaleY = 10},				-- 6
			{trueSizeX = 10 / 32},	-- 7
			{trueSizeY = 10 / 32},	-- 8
		})
			--
			-- entityManager:forEach("ri", function(Data, Entity, Renderer, Transform)
			-- 	-- Feint.Log.log("Entity %02d: Transform[x: %0.4f, y: %0.4f]\n", Entity, Data[Transform], Data[Transform + 1])
			-- 	-- local x = Data[Transform]
			-- 	-- local y = Data[Transform + 1]
			-- 	local x = Feint.Math.random2(Feint.Graphics.RenderSize.x / 2)
			-- 	local y = Feint.Math.random2(-Feint.Graphics.RenderSize.y / 2, Feint.Graphics.RenderSize.y / 2 - 300)
			-- 	local sizeX = Data[Transform + 3]
			-- 	local sizeY = Data[Transform + 4]
			-- 	local scaleX = Data[Transform + 5]
			-- 	local scaleY = Data[Transform + 6]
			-- 	local trueSizeX = scaleX / sizeX
			-- 	local trueSizeY = scaleY / sizeY
			--
			-- 	Data[Transform] = x
			-- 	Data[Transform + 1] = y
			-- 	Data[Transform + 7] = trueSizeX
			-- 	Data[Transform + 8] = trueSizeY
			-- end)
	end
	if key == "a" then
		local graphics = Feint.Graphics
		print(graphics.ScreenToRenderRatio)
		graphics.RenderSize = graphics.RenderSize % Feint.Math.Vec2.new(0.5, 0.5)
		graphics.RenderToScreenRatio = graphics.ScreenSize / graphics.RenderSize
		graphics.ScreenToRenderRatio = graphics.RenderSize / graphics.ScreenSize
		print(graphics.ScreenToRenderRatio)
	end
	if key == "z" then
		Feint.Graphics.toggleInterpolation()
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
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem1"))
	-- World.DefaultWorld:registerSystem(Feint.ECS.System:new("testSystem2"))
	-- World.DefaultWorld:generateUpdateOrderList()


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
		local channel = love.thread.getChannel("thread_data_"..i)
		channel:push(threadData)

		Feint.Log.logln("WAITING FOR THREAD %d", i)
		local wait = false
		while not wait and wait ~= threadData do
			wait = channel:demand()
			Feint.Log.logln("RECIEVED", wait)
		end
		Feint.Log.logln("DONE WAITING FOR THREAD %d", i)

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
	end
	--]]
end

Feint.Util.Debug.PRINT_ENV(_G, false)

local run = Feint.Run

--[[
local	L_AVG_TPS_LIST = {}
for i = 1, G_AVG_TPS_DELTA_ITERATIONS, 1 do
	L_AVG_TPS_LIST[i] = 0
end
local L_AVG_TPS_LIST_INDEX = 1
local L_AVG_TPS_SUM = 0
]]

local getTime = love.timer.getTime
local avg = 0
local avgTimes = 0

function love.update(dt)
	Feint.Graphics.clear()

		local graphics = Feint.Graphics

		-- print(((0.5 + math.sin(Feint.Util.Core.getTime()) * 0.5) * 0.1 + 0.9))
		graphics.RenderSize = Feint.Math.Vec2.new(1280, 720)-- * ((0.5 + math.sin(Feint.Util.Core.getTime()) * 0.5) * 0.1 + 0.9)
		graphics.RenderToScreenRatio = graphics.ScreenSize / graphics.RenderSize
		graphics.ScreenToRenderRatio = graphics.RenderSize / graphics.ScreenSize

	local startTime = getTime()

	--[[ -- unreliable tickrate counter
	local tickrate = run.rate + run.accum
	do
		G_TPS_DELTA = G_TPS_DELTA + (tickrate - G_TPS_DELTA) * (1 - G_TPS_DELTA_SMOOTHNESS)
		G_TPS = 1 / G_TPS_DELTA
	end

	do
		L_AVG_TPS_SUM = L_AVG_TPS_SUM -	L_AVG_TPS_LIST[L_AVG_TPS_LIST_INDEX]
		L_AVG_TPS_SUM = L_AVG_TPS_SUM + tickrate
		L_AVG_TPS_LIST[L_AVG_TPS_LIST_INDEX] = tickrate
		L_AVG_TPS_LIST_INDEX = L_AVG_TPS_LIST_INDEX % G_AVG_TPS_DELTA_ITERATIONS + 1
		G_AVG_TPS_DELTA = L_AVG_TPS_SUM / G_AVG_TPS_DELTA_ITERATIONS

		G_AVG_TPS = 1 / G_AVG_TPS_DELTA
	end
	-]]

	if true then
		World.DefaultWorld:update(dt) -- luacheck: ignore
	end
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
	if false and Feint.Run.rate > 0 then
		local endTime = getTime() - startTime
		Feint.Log.log("TIME: %9.6fms, %9.6f%% of frame time\n", endTime * 1000, endTime / (1 / 60) * 100)
		avg = avg + endTime
		avgTimes = avgTimes + 1
		Feint.Log.log("AVG:  %9.6fms, %9.6f%% of frame time\n", avg / avgTimes * 1000, endTime / (1 / 60) * 100)
	end
end


local DEFAULT_FONT = love.graphics.newFont("Assets/fonts/FiraCode-Regular.ttf", 32)
local DEFAULT_FONT_HEIGHT = DEFAULT_FONT:getHeight()
love.graphics.setFont(DEFAULT_FONT)

local	fpsList = {}
for i = 1, run.G_AVG_FPS_DELTA_ITERATIONS, 1 do
	fpsList[i] = 0
end
local fpsIndex = 1
local fpsSum = 0

local function getMemoryUsageKiB()
	return collectgarbage("count") * (1000 / 1024)
end
local function getMemoryUsageKb()
	return collectgarbage("count")
end

local canvas = love.graphics.newCanvas(Feint.Graphics.RenderSize.x, Feint.Graphics.RenderSize.y, {msaa = 0})
local debug = love.graphics.newCanvas(Feint.Graphics.RenderSize.x, Feint.Graphics.RenderSize.y, {msaa = 0})

local ui = Feint.UI.Immediate
ui.Initialize()
function love.draw(dt)
	do
		run.G_FPS_DELTA = run.G_FPS_DELTA + (run.dt - run.G_FPS_DELTA) * (1 - run.G_FPS_DELTA_SMOOTHNESS)
		run.G_FPS = 1/ run.G_FPS_DELTA
	end

	do
		fpsSum = fpsSum -	fpsList[fpsIndex]
		fpsSum = fpsSum + run.dt
		fpsList[fpsIndex] = run.dt
		fpsIndex = fpsIndex % run.G_AVG_FPS_DELTA_ITERATIONS + 1
		run.G_AVG_FPS_DELTA = fpsSum / run.G_AVG_FPS_DELTA_ITERATIONS

		run.G_AVG_FPS = 1 / run.G_AVG_FPS_DELTA
	end

	-- local smoothing = 1 - 0.1
	-- G_FPS = (G_FPS * smoothing) + ((love.mouse.getX()) * (1.0-smoothing))

	run.G_INT = run.accum / math.max(0, run.rate)

	-- if currentGame then
	-- 	currentGame.draw(dt)
	-- 	if Slab then
	-- 		Slab.Draw(dt)
	-- 	end
	-- end

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.push()
	love.graphics.translate(Feint.Graphics.RenderSize.x / 2, -Feint.Graphics.RenderSize.y / 2)
	-- love.graphics.setWireframe(true)
	Feint.Graphics.updateInterpolate(run.accum)
	Feint.Graphics.draw()
	-- love.graphics.setWireframe(false)
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, Feint.Graphics.RenderToScreenRatio.x, Feint.Graphics.RenderToScreenRatio.y, 0, 0)
	-- love.graphics.draw(canvas, 0, 0, 0, 1, 1, 0, 0)

	love.graphics.printf(
		string.format("FPS:      %7.2f, DT:      %7.4fms\n",
		run.G_FPS, 1000 * run.G_FPS_DELTA), 0, 0, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)
	love.graphics.printf(
		string.format("FPS AVG:  %7.2f, DT AVG:  %7.4fms\n", run.G_AVG_FPS, 1000 * run.G_AVG_FPS_DELTA),
		0, DEFAULT_FONT_HEIGHT / 2, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	love.graphics.printf(
		string.format("FPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / run.dt, 1000 * run.dt),
		0, DEFAULT_FONT_HEIGHT / 2 * 2, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- love.graphics.printf(
	-- 	string.format("TPS:      %7.2f, DT:      %7.4fms\n", run.G_TPS, 1000 * run.G_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 4, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- love.graphics.printf(
	-- 	string.format("TPS AVG:  %7.2f, DT AVG:  %7.4fms\n", run.G_AVG_TPS, 1000 * run.G_AVG_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 5, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- love.graphics.printf(
	-- 	string.format("TPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / run.rate, 1000 * run.rate),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 6, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )

	love.graphics.printf(string.format("Memory Usage (MiB):   %12.2f", getMemoryUsageKiB() / 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 4, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	love.graphics.printf(string.format("Memory Usage (KiB):   %12.2f", getMemoryUsageKiB()),
		0, DEFAULT_FONT_HEIGHT / 2 * 5, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	love.graphics.printf(string.format("Memory Usage (bytes): %12.2f", getMemoryUsageKiB() * 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 6, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	local stats = love.graphics.getStats()
	love.graphics.printf(string.format("Draw calls: %d", stats.drawcalls),
		0, DEFAULT_FONT_HEIGHT / 2 * 7, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	love.graphics.printf(string.format("Texture Memory: %d bytes", stats.texturememory),
		0, DEFAULT_FONT_HEIGHT / 2 * 8, Feint.Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
end
function love.quit()
	-- if currentGame then
	-- 	currentGame.quit()
	-- end
end

-- PRINT_ENV(_ENV, false)

printf("\n")
Feint.Log.log("Exiting run.lua\n")
