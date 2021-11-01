-- CORE FILE

-- luacheck: push ignore
local Paths = Feint.Core.Paths
local Math = Feint.Math
local Util = Feint.Util
local Graphics = Feint.Core.Graphics
local LoveGraphics = love.graphics
local Time = Feint.Core.Time
local Log = Feint.Log
local Core = Feint.Core
local Input = Feint.Core.Input
local Debug = Feint.Core.Util.Debug
-- Util.Debug.logLevel = 2
Debug:setDebugLevel(10)

-- It sets up a default world and passes love callbacks to the ECS
local World = Feint.ECS.World
local Mouse = Input.Mouse

-- function cache
local getTime = love.timer.getTime

-- fps counter variables
local	fpsList
local fpsIndex
local fpsSum

local fpsGraph1
local memGraph1

local DEFAULT_FONT
local DEFAULT_FONT_BOLD
local DEFAULT_FONT_HEIGHT

-- direct requires (BAD BUT EASY)
local ffi = require("ffi")
local fpsGraph = require("Feint_Engine.lib.FPSGraph")

-- luacheck: pop ignore

-- local oldRate = Time.rate
function love.keypressed(key, ...)
	if key == "space" then
		print(Time:isPaused())
		if Time:isPaused() then
			print("PLAY")
			Time:unpause()
		else
			print("PAUSE")
			Time:pause()
		end
		-- if Time.rate == 0 then
		-- 	print("PLAY")
		-- 	Time.rate = oldRate
		-- 	Time.accum = 0
		-- 	Time.dt = 0
		-- 	-- Time.pause = false
		-- else
		-- 	print("PAUSE")
		-- 	oldRate = Time.rate
		-- 	Time.rate = 0
		-- 	-- Time.pause = true
		-- end
	end
	if key == "q" then
		local world = World.DefaultWorld
		local entityManager = world.EntityManager
		local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
		local archetype = entityManager:getArchetype({Renderer, Transform})
		local entity = entityManager:createEntityFromArchetype(archetype)

		entityManager:setComponentData(entity, Transform, {
			{x = Math.random2(Graphics.RenderSize.x / 2)},
			{y = Math.random2(-Graphics.RenderSize.y / 2, Graphics.RenderSize.y / 2 - 300)},
			{angle = 0},
			{sizeX = 32},
			{sizeY = 32},
			{scaleX = 10},
			{scaleY = 10},
			{trueSizeX = 10 / 32},
			{trueSizeY = 10 / 32},
		})
	end
	-- if key == "a" then
	-- 	Graphics:setRenderResolution((Graphics.RenderSize % Math.Vec2.new(0.5, 0.5)):split())
	-- end
	-- if key == "d" then
	-- 	Graphics:setRenderResolution((Graphics.RenderSize % Math.Vec2.new(2, 2)):split())
	-- end
	if key == "z" then
		Graphics.toggleInterpolation()
	end
end
function love.keyreleased(...)
end
function love.mousemoved(x, y, dx, dy)
	-- print(x, y)
	Input.mousemoved(x, y, dx, dy)
end

function love.joystickadded(joystick)
	print("ADDED", joystick)
	-- print(joystick:getGamepadMappingString())
	Input:joystickadded(joystick)
end
function love.joystickremoved(joystick)
	print("REMOVED", joystick)
end
function love.gamepadaxis(joystick, axis, value)
	Input:gamepadaxis(joystick, axis, value)
	-- print("gamepadaxis", joystick, axis, value)
end
function love.gamepadpressed(joystick, button)
	Input:gamepadpressed(joystick, button)
	-- print("gamepadpressed", joystick, button)
end
function love.gamepadreleased(joystick, button)
	Input:gamepadreleased(joystick, button)
	-- print("gamepadreleased", joystick, button)
end
function love.joystickhat(joystick, hat, direction)
	Input:joystickhat(joystick, hat, direction)
	-- print("joystickhat", joystick, hat, direction)
end
function love.joystickaxis(joystick, axis, value)
	Input:joystickaxis(joystick, axis, value)
-- 	print("joystickaxis", joystick, axis, value)
end
function love.joystickpressed(joystick, button)
	Input:joystickpressed(joystick, button)
	-- print("joystickpressed", joystick, button)
end
function love.joystickreleased(joystick, button)
	Input:joystickpressed(joystick, button)
	-- print("joystickreleased", joystick, button)
end


function love.mousepressed(x, y, button, isTouch)
	Input.mousepressed(x, y, button, isTouch)
end
function love.mousereleased(x, y, button, isTouch)
	Input.mousereleased(x, y, button, isTouch)
end

function love.threaderror(thread, message)
	error(string.format("Thread (%s): Error \"%s\"\n", thread, message), 2)
end
local uiCanvas = love.graphics.newCanvas()
local debugCanvas = love.graphics.newCanvas()--Graphics.ScreenSize.x, Graphics.ScreenSize.y)
function love.resize(x, y)
	Graphics:setScreenResolution(x, y)
	-- love.draw()
	-- Graphics:draw()
	uiCanvas = love.graphics.newCanvas()
	debugCanvas = love.graphics.newCanvas()--Graphics.ScreenSize.x, Graphics.ScreenSize.y)
end

function love.load()
	Time.framerate = 60 -- framerate cap
	Time.rate = 1 / 60 -- update dt
	Time.sleep = 0.001 -- don't toast the CPU
	Time:setSpeed(1) -- default game speed

	fpsList = {}
	for i = 1, Time.AVG_FPS_DELTA_ITERATIONS, 1 do
		fpsList[i] = 0
	end
	fpsIndex = 1
	fpsSum = 0

	Math.G_SEED = love.timer.getTime()
	math.randomseed(Math.G_SEED)
	love.math.setRandomSeed(Math.G_SEED)

	DEFAULT_FONT = LoveGraphics.newFont("Assets/fonts/FiraCode-Regular.ttf", 28)
	DEFAULT_FONT_BOLD = LoveGraphics.newFont("Assets/fonts/FiraCode-Bold.ttf", 28)
	DEFAULT_FONT_HEIGHT = DEFAULT_FONT:getHeight()
	DEFAULT_UI_FONT = LoveGraphics.newFont("Assets/fonts/FiraCode-Medium.ttf", 12)

	for k, v in pairs(Feint.Core.AssetManager) do
		print(k, v)
	end
	Feint.Core.AssetManager:registerAsset(DEFAULT_FONT, "Default Font", Feint.Core.AssetManager.FONT)
	Feint.Core.AssetManager:registerAsset(DEFAULT_FONT_BOLD, "Default Font Bold", Feint.Core.AssetManager.FONT)
	Feint.Core.AssetManager:registerAsset(DEFAULT_UI_FONT, "Default UI Font", Feint.Core.AssetManager.FONT)

	LoveGraphics.setFont(DEFAULT_FONT)

	-- fpsGraph1 = fpsGraph.createGraph(350, DEFAULT_FONT_HEIGHT / 2 * 8)
	-- memGraph1 = fpsGraph.createGraph(350, DEFAULT_FONT_HEIGHT / 2 * 10)

	-- Immediate Mode GUI
	Graphics.UI.Immediate.DisableDocks({"Left", "Right", "Bottom"})
	Graphics.UI.Immediate.Initialize()
	Graphics.UI.Immediate.Update(Time.rate)
	Graphics.UI.Immediate.PushFont(DEFAULT_UI_FONT)
	print(Feint.Core.Graphics.UI.Immediate.GetINIStatePath())

	Feint.ECS:init()

	-- Threads
	for i = 1, 0, 1 do
		Feint.Core.Thread:newWorker(i)
	end
	Feint.Core.Thread:startWorkers()

	-- love.timer.sleep(0.1)
	-- for i = 1, Feint.Core.Thread:getNumWorkers(), 1 do
	-- 	Log:logln("STARTING THREAD %d", i)
	-- 	Feint.Core.Thread:startWorker(i)
	-- end
	for i = 1, Feint.Core.Thread:getNumWorkers(), 1 do
		local channel = love.thread.getChannel("thread_data_"..i)
		Log:logln("WAITING FOR THREAD %d", i)

		local status
		status = channel:demand(1)

		Log:logln("RECIEVED FROM THREAD %d: %s", i, status)
		-- Log:logln("DONE WAITING FOR THREAD %d", i)
	end

end

-- local SlabTest = require(Paths.Lib .. "Slab-0_7_2.SlabTest")
function love.update(dt)
	Time:update()
	-- Time:setSpeed(Mouse.PositionNormalized.x)
	Graphics.clear()
	Graphics:resetQueues()
	Graphics:update()

	local startTime = getTime()

	if Time.tick % 1 == 0 then
		World.DefaultWorld:update(dt) -- luacheck: ignore

		-- local arc = World.DefaultWorld.EntityManager.archetypes["RendererTransform"]
		-- local chunk = World.DefaultWorld.EntityManager.archetypeChunks[arc][1]
		-- Feint.Core.Thread:queue(arc, chunk, function(Entity, Components)
		-- 	Components.Transform.x = Components.Transform.x + 10
		-- end)
		-- Feint.Core.Thread:queue(arc, chunk, function(Entity, Components)
		-- 	Components.Transform.y = Components.Transform.y - 5
		-- end)

		Feint.Core.Thread:update()
	end

	-- Graphics.processAddQueue()	-- process all pending draw queue insertions
	-- Graphics.processQueue()		-- process all draw data updates

	if Graphics.UI.Immediate then
		-- Graphics.UI.Immediate.Update(dt)
		-- World.DefaultWorld:IMGUI(dt)
		-- SlabTest.Begin()
		Graphics.UI.Immediate.Update(dt)
		World.DefaultWorld:IMGUI(dt)

		local previousCanvas = love.graphics.getCanvas()
		love.graphics.setCanvas(uiCanvas)
		love.graphics.clear()
		Graphics.UI.Immediate.Draw()
		love.graphics.setCanvas(previousCanvas)
	end

	local endTime = getTime()

	Time.UPDATE_DT = endTime - startTime

	Time.UPDATE_TIME = Time.UPDATE_TIME + (Time.UPDATE_DT - Time.UPDATE_TIME) * (1 - Time.UPDATE_TIME_SMOOTHNESS)

	Time.UPDATE_TIME_PERCENT_FRAME = Time.UPDATE_TIME / (Time.rate) * 100


	-- fpsGraph.updateFPS(fpsGraph1, Time.rate, Time.FPS)
	-- fpsGraph.updateMem(memGraph1, Time.rate)
end

local function updateRender(dt) -- luacheck: ignore
end

local function debugDraw()
	local oldCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(debugCanvas)
	love.graphics.clear()
	LoveGraphics.setFont(DEFAULT_FONT)
	LoveGraphics.printf(
		Time:isPaused() and string.format("Game Speed: %s\n", "Paused") or
		string.format("Game Speed: %.3f\n", Time:getSpeed()),
		400, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)

	-- FPS
	LoveGraphics.printf(
		string.format("FPS:      %7.2f, DT:      %7.4fms\n", Time.FPS, 1000 * Time.FPS_DELTA),
		0, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)
	-- [[
	LoveGraphics.printf(
		string.format("FPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Time.AVG_FPS, 1000 * Time.AVG_FPS_DELTA),
		0, DEFAULT_FONT_HEIGHT / 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("FPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Time.dt, 1000 * Time.dt),
		0, DEFAULT_FONT_HEIGHT / 2 * 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- UPDATE TIME
	LoveGraphics.printf(
		string.format("UPDATE:     %8.4fms, %6.2f%% 60Hz\n", 1000 * Time.UPDATE_TIME, Time.UPDATE_TIME_PERCENT_FRAME),
		0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE AVG: %8.4fms, %6.2f%% 60Hz\n", 0, 0),
		0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE TRUE:%8.4fms, %6.2f%% 60Hz\n", 1000 * Time.UPDATE_DT, Time.UPDATE_DT / (Time.rate) * 100),
		0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	-- RENDER TIME
	LoveGraphics.printf(
		string.format("RENDER:     %8.4fms, %6.2f%% Frame\n", 1000 * Time.RENDER_TIME, Time.RENDER_TIME_PERCENT_FRAME),
		350, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER AVG: %8.4fms, %6.2f%% Frame\n", 0, 0),
		350, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER TRUE:%8.4fms, %6.2f%% Frame\n", 1000 * Time.RENDER_DT, Time.RENDER_DT / (Time.rate) * 100),
		350, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	LoveGraphics.printf(
		string.format("FRAME BUDGET: %6.2f%% Frame\n", Time.UPDATE_TIME_PERCENT_FRAME + Time.RENDER_TIME_PERCENT_FRAME),
		400, DEFAULT_FONT_HEIGHT / 2 * 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)


	-- LoveGraphics.printf(
	-- 	string.format("TPS:      %7.2f, DT:      %7.4fms\n", Time.TPS, 1000 * Time.TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Time.AVTPS, 1000 * Time.AVTPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Time.rate, 1000 * Time.rate),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )

	-- MEMORY
	LoveGraphics.printf(string.format("Memory Usage (MiB):   %12.2f", Core.Util:getMemoryUsageKiB() / 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 8, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (KiB):   %12.2f", Core.Util:getMemoryUsageKiB()),
		0, DEFAULT_FONT_HEIGHT / 2 * 9, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (bytes): %12d", Core.Util:getMemoryUsageBytes()),
		0, DEFAULT_FONT_HEIGHT / 2 * 10, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- DRAWING
	local stats = LoveGraphics.getStats()
	LoveGraphics.printf(string.format("Draw calls: %d", stats.drawcalls),
		0, DEFAULT_FONT_HEIGHT / 2 * 12, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Texture Memory: %12.2f Mebibytes", stats.texturememory / 1048576),
		0, DEFAULT_FONT_HEIGHT / 2 * 13, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	--]]

	LoveGraphics.printf(string.format("Entity Count: %d", World.DefaultWorld.EntityManager:getEntityCount()),
		0, DEFAULT_FONT_HEIGHT / 2 * 15, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	local queueCacheData = World.DefaultWorld.EntityManager:getQueueCacheDebug()
	local i = 0
	for k, v in pairs(queueCacheData) do
		i = i + 1
		LoveGraphics.printf(string.format("%-20.20s: %0.6f ms", k, v.runTime * 1000),
			0, DEFAULT_FONT_HEIGHT / 2 * (16 + i - 1), Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
		)
	end
	love.graphics.setCanvas(oldCanvas)
end
function love.draw(dt)
	do
		Time.FPS_DELTA = Time.FPS_DELTA + (Time.dt - Time.FPS_DELTA) * (1 - Time.FPS_DELTA_SMOOTHNESS)
		Time.FPS = 1 / Time.FPS_DELTA
	end

	do
		fpsSum = fpsSum -	fpsList[fpsIndex] + Time.dt
		fpsList[fpsIndex] = Time.dt
		fpsIndex = fpsIndex % Time.AVG_FPS_DELTA_ITERATIONS + 1
		Time.AVG_FPS_DELTA = fpsSum / Time.AVG_FPS_DELTA_ITERATIONS

		Time.AVG_FPS = 1 / Time.AVG_FPS_DELTA
	end

	Time.G_INT = Time.accum / math.max(0, Time.rate)

	local startTime = getTime()

	Graphics:updateInterpolate(Time.accum)
	Graphics:draw()

	debugDraw()

	local function outline(canvas, depth, x, y)
		love.graphics.setColor(0, 0, 0, 1)
		for i = 0, depth - 1, 1 do
			love.graphics.draw(canvas, x * i, y * i, 0, 1, 1, 0, 0, 0, 0)
		end
	end

	outline(debugCanvas, 3, 1, 0)
	outline(debugCanvas, 3, 1, 1)
	outline(debugCanvas, 3, 0, 1)
	outline(debugCanvas, 3, -1, 1)
	outline(debugCanvas, 3, -1, 0)
	outline(debugCanvas, 3, -1, -1)
	outline(debugCanvas, 3, 0, -1)
	outline(debugCanvas, 3, 1, -1)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(debugCanvas, 0, 0, 0, 1, 1, 0, 0, 0, 0)

	love.graphics.draw(uiCanvas, 0, 0, 0, 1, 1, 0, 0, 0, 0)

	-- local dt = 1 / 60
	-- Graphics.UI.Immediate.Update(dt)
	-- World.DefaultWorld:IMGUI(dt)
	-- Graphics.UI.Immediate.Draw()

	local endTime = getTime()

	Time.RENDER_DT = endTime - startTime

	Time.RENDER_TIME = Time.RENDER_TIME + (Time.RENDER_DT - Time.RENDER_TIME) * (1 - Time.RENDER_TIME_SMOOTHNESS)

	Time.RENDER_TIME_PERCENT_FRAME = Time.RENDER_TIME / (Time.rate) * 100

	--[[
	local f = 60
	acc = acc + Time.RENDER_DT * f
	while acc > 1 / 60 do
		updateRender(acc)
		acc = acc - 1 / 60
	end
	--]]
end
function love.quit()
end

Debug.PRINT_ENV(_G, false)

printf("\n")
Log.log("Exiting run.lua\n")
