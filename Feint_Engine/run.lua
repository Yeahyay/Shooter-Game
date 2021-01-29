-- CORE FILE

local Paths = Feint.Core.Paths
local Math = Feint.Math
local Util = Feint.Util
local Graphics = Feint.Core.Graphics
local LoveGraphics = love.graphics
local Run = Feint.Core.Time
local Log = Feint.Log
local Core = Feint.Core
local Input = Feint.Core.Input

-- It sets up a default world and passes love callbacks to the ECS
local World = Feint.ECS.World

local oldRate = Run.rate
function love.keypressed(key, ...)
	print("kkmlk;ml")
	if key == "space" then
		print(Run:isPaused())
		if Run:isPaused() then
			print("PLAY")
			Run:unpause()
		else
			print("PAUSE")
			Run:pause()
		end
		-- if Run.rate == 0 then
		-- 	print("PLAY")
		-- 	Run.rate = oldRate
		-- 	Run.accum = 0
		-- 	Run.dt = 0
		-- 	-- Run.pause = false
		-- else
		-- 	print("PAUSE")
		-- 	oldRate = Run.rate
		-- 	Run.rate = 0
		-- 	-- Run.pause = true
		-- end
	end
	if key == "q" then
		local world = World.DefaultWorld
		local entityManager = world.EntityManager
		local Renderer, Transform = world:getComponent("Renderer"), world:getComponent("Transform")
		local archetype = entityManager:getArchetype({Renderer, Transform})
		local entity = entityManager:CreateEntity(archetype)

		entityManager:setComponentData(entity, Transform, {
			{x = Math.random2(Graphics.RenderSize.x / 2)},
			{y = Math.random2(-Graphics.RenderSize.y / 2, Graphics.RenderSize.y / 2 - 300)},
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
		Graphics:setRenderResolution((Graphics.RenderSize % Math.Vec2.new(0.5, 0.5)):split())
	end
	if key == "d" then
		Graphics:setRenderResolution((Graphics.RenderSize % Math.Vec2.new(2, 2)):split())
	end
	if key == "z" then
		Graphics.toggleInterpolation()
	end
end
function love.keyreleased(...)
end

function love.mousemoved(x, y, dx, dy)
	Input.mousemoved(x, y, dx, dy)
end

function love.mousepressed(...)
end
function love.mousereleased(...)
end

function love.threaderror(thread, message)
	error(string.format("Thread (%s): Error \"%s\"\n", thread, message), 2)
end
function love.resize(x, y)
	Graphics:setScreenResolution(x, y)
	-- love.draw()
	-- Graphics:draw()
end
local ffi = require("ffi")
function love.load()
	Run.framerate = 60 -- framerate cap
	Run.rate = 1 / 60 -- update dt
	Run.sleep = 0.001
	Run:setSpeed(1)

	love.math.setRandomSeed(Math.G_SEED)

	Feint.ECS:init()
	-- Feint.ECS.World.DefaultWorld.EntityManager.archetypeChunks[arc][1]

	-- after the new module system, this might not work
	-- to future me, please fix
	-- [[
	for i = 1, 4, 1 do
		Feint.Core.Thread:newWorker(i, nil)
	end
	love.timer.sleep(0.1)
	for i = 1, Feint.Core.Thread:getNumWorkers(), 1 do
		Log:logln("STARTING THREAD %d", i)
		Feint.Core.Thread:startWorker(i)

		local arc = Feint.ECS.World.DefaultWorld.EntityManager.archetypes["RendererTransform"]
		local chunk = Feint.ECS.World.DefaultWorld.EntityManager.archetypeChunks[arc][i]
		local s = ffi.string(
			chunk.data,
			chunk.numEntities * chunk.entitySizeBytes
		)
		local threadData = {
			tick = Run.tick,
			entities = s, --love.data.newByteData(s),
			-- entities = chunk.data,
			length = chunk.numEntities,
			archetypeString = arc.archetypeString,
			operation = string.dump(function(entity)
				-- print(entity.Transform.x)
				entity.Transform.x = entity.Transform.x + 10
			end)
		}

		local channel = love.thread.getChannel("thread_data_"..i)

		-- channel:push(threadData)

		Log:logln("WAITING FOR THREAD %d", i)
		local wait
		wait = channel:demand(2)
		-- while not wait do--and wait ~= threadData do
			Log:logln("RECIEVED FROM THREAD %d: %s", i, wait)
		-- end
		channel:supply(true)

		wait = channel:demand(2)
		Log:logln("RECIEVED FROM THREAD %d: %s", i, wait)

		Log:logln("DONE WAITING FOR THREAD %d", i)
	end
	print(Feint.Core.FFI.typeSize.cstring)
	print(ffi.alignof("struct component_Transform"))
	print(ffi.offsetof("struct component_Transform", "sizeX"))
	--]]

	Graphics.UI.Immediate.Initialize()

	-- Feint.ECS:init()
end

local getTime = love.timer.getTime
local Mouse = Input.Mouse
function love.update(dt)
	Run:update()
	Run:setSpeed(Mouse.PositionNormalized.x)
	Graphics.clear()

	-- local s = math.max(math.floor(Mouse.PositionRaw.y / 8) * 8 / Graphics.ScreenSize.y, 0.001)
	-- print(s)
	-- Graphics.RenderScale = Feint.Math.Vec2.new(s, s)

	local startTime = getTime()

	if true then
		World.DefaultWorld:update(dt) -- luacheck: ignore

		io.write("\n")
		Feint.Log:logln("SEND PHASE")
		for i = 1, Feint.Core.Thread:getNumWorkers(), 1 do
			local channel = love.thread.getChannel("thread_data_" .. i)

			local arc = Feint.ECS.World.DefaultWorld.EntityManager.archetypes["RendererTransform"]
			local chunk = Feint.ECS.World.DefaultWorld.EntityManager.archetypeChunks[arc][i]
			local s = ffi.string(
				chunk.data,
				chunk.numEntities * chunk.entitySizeBytes
			)
			local threadData = {
				tick = Run.tick,
				entities = s, --love.data.newByteData(s),
				-- entities = chunk.data,
				length = chunk.numEntities,
				sizeBytes = chunk.numEntities * chunk.entitySizeBytes,
				archetypeString = arc.archetypeString,
				operation = string.dump(function(entity)
					-- print(entity.Transform.x)
					entity.Transform.x = entity.Transform.x + 1
				end)
			}

			Feint.Log:logln("Sending: %s tick %d", threadData, threadData.tick)
			channel:push(threadData)
		end

		io.write("\n")
		Feint.Log:logln("RECEIVE PHASE")
		for i = 1, Feint.Core.Thread:getNumWorkers(), 1 do
			local channel = love.thread.getChannel("thread_data_" .. i)
			local status
			Feint.Log:logln("Channel %d count: %s", i, channel:getCount())
			print(channel:peek())
			-- repeat
				status = channel:demand(Run.rate)
				-- print(status)
			-- until status == 0
			print(channel:peek())
			if status == 0 then
				local data = channel:demand(Run.rate)

				local arc = Feint.ECS.World.DefaultWorld.EntityManager.archetypes["RendererTransform"]
				local chunk = Feint.ECS.World.DefaultWorld.EntityManager.archetypeChunks[arc][i]

				ffi.copy(chunk.data, data.entities, data.sizeBytes)

				-- Feint.Log:logln("status: %s", status)
				-- Feint.Log:logln("Channel %d count: %d", i, channel:getCount())
			else
				Feint.Log:logln("Thread %d desynced", i)
				-- Run:pause()
			end
		end
	end

	-- Graphics.processAddQueue()	-- process all pending draw queue insertions
	-- Graphics.processQueue()		-- process all draw data updates

	if Graphics.UI.Immediate then
		Graphics.UI.Immediate.Update(dt)
	end

	local endTime = getTime()

	Run.G_UPDATE_DT = endTime - startTime

	Run.G_UPDATE_TIME = Run.G_UPDATE_TIME + (Run.G_UPDATE_DT - Run.G_UPDATE_TIME) * (1 - Run.G_UPDATE_TIME_SMOOTHNESS)

	Run.G_UPDATE_TIME_PERCENT_FRAME = Run.G_UPDATE_TIME / (Run.rate) * 100

	Graphics.UI.Immediate.Update(Run.G_RENDER_DT)
end

local function updateRender(dt) -- luacheck: ignore
end

local DEFAULT_FONT = LoveGraphics.newFont("Assets/fonts/FiraCode-Regular.ttf", 28)
-- local DEFAULT_FONT_BOLD = LoveGraphics.newFont("Assets/fonts/FiraCode-Bold.ttf", 28)
local DEFAULT_FONT_HEIGHT = DEFAULT_FONT:getHeight()
LoveGraphics.setFont(DEFAULT_FONT)

local	fpsList = {}
for i = 1, Run.G_AVG_FPS_DELTA_ITERATIONS, 1 do
	fpsList[i] = 0
end
local fpsIndex = 1
local fpsSum = 0

-- local debug = LoveGraphics.newCanvas(Graphics.RenderSize.x, Graphics.RenderSize.y, {msaa = 0})

-- local acc = 0
local function debugDraw()
	LoveGraphics.printf(
		Run:isPaused() and string.format("Game Speed: %s\n", "Paused") or
		string.format("Game Speed: %.3f\n", Run:getSpeed()),
		400, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)

	-- FPS
	LoveGraphics.printf(
		string.format("FPS:      %7.2f, DT:      %7.4fms\n",
		Run.G_FPS, 1000 * Run.G_FPS_DELTA), 0, 0, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5)
	-- [[
	LoveGraphics.printf(
		string.format("FPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Run.G_AVG_FPS, 1000 * Run.G_AVG_FPS_DELTA),
		0, DEFAULT_FONT_HEIGHT / 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("FPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Run.dt, 1000 * Run.dt),
		0, DEFAULT_FONT_HEIGHT / 2 * 2, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- UPDATE TIME
	LoveGraphics.printf(
		string.format("UPDATE:     %8.4fms, %6.2f%% 60Hz\n", 1000 * Run.G_UPDATE_TIME, Run.G_UPDATE_TIME_PERCENT_FRAME),
		0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE AVG: %8.4fms, %6.2f%% 60Hz\n", 0, 0),
		0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("UPDATE TRUE:%8.4fms, %6.2f%% 60Hz\n", 1000 * Run.G_UPDATE_DT, Run.G_UPDATE_DT / (Run.rate) * 100),
		0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	-- RENDER TIME
	LoveGraphics.printf(
		string.format("RENDER:     %8.4fms, %6.2f%% Frame\n", 1000 * Run.G_RENDER_TIME, Run.G_RENDER_TIME_PERCENT_FRAME),
		350, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER AVG: %8.4fms, %6.2f%% Frame\n", 0, 0),
		350, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(
		string.format("RENDER TRUE:%8.4fms, %6.2f%% Frame\n", 1000 * Run.G_RENDER_DT, Run.G_RENDER_DT / (Run.rate) * 100),
		350, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)


	-- LoveGraphics.printf(
	-- 	string.format("TPS:      %7.2f, DT:      %7.4fms\n", Run.G_TPS, 1000 * Run.G_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 4, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS AVG:  %7.2f, DT AVG:  %7.4fms\n", Run.G_AVG_TPS, 1000 * Run.G_AVG_TPS_DELTA),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 5, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )
	-- LoveGraphics.printf(
	-- 	string.format("TPS TRUE: %7.2f, DT TRUE: %7.4fms\n", 1 / Run.rate, 1000 * Run.rate),
	-- 	0, DEFAULT_FONT_HEIGHT / 2 * 6, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	-- )

	-- MEMORY
	LoveGraphics.printf(string.format("Memory Usage (MiB):   %12.2f", Core.Util.getMemoryUsageKiB() / 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 8, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (KiB):   %12.2f", Core.Util.getMemoryUsageKiB()),
		0, DEFAULT_FONT_HEIGHT / 2 * 9, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Memory Usage (bytes): %12.2f", Core.Util.getMemoryUsageKiB() * 1024),
		0, DEFAULT_FONT_HEIGHT / 2 * 10, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)

	-- DRAWING
	local stats = LoveGraphics.getStats()
	LoveGraphics.printf(string.format("Draw calls: %d", stats.drawcalls),
		0, DEFAULT_FONT_HEIGHT / 2 * 12, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	LoveGraphics.printf(string.format("Texture Memory: %d bytes", stats.texturememory),
		0, DEFAULT_FONT_HEIGHT / 2 * 13, Graphics.ScreenSize.x, "left", 0, 0.5, 0.5
	)
	--]]
end
function love.draw(dt)
	do
		Run.G_FPS_DELTA = Run.G_FPS_DELTA + (Run.dt - Run.G_FPS_DELTA) * (1 - Run.G_FPS_DELTA_SMOOTHNESS)
		Run.G_FPS = 1 / Run.G_FPS_DELTA
	end

	do
		fpsSum = fpsSum -	fpsList[fpsIndex] + Run.dt
		fpsList[fpsIndex] = Run.dt
		fpsIndex = fpsIndex % Run.G_AVG_FPS_DELTA_ITERATIONS + 1
		Run.G_AVG_FPS_DELTA = fpsSum / Run.G_AVG_FPS_DELTA_ITERATIONS

		Run.G_AVG_FPS = 1 / Run.G_AVG_FPS_DELTA
	end

	Run.G_INT = Run.accum / math.max(0, Run.rate)

	local startTime = getTime()

	-- LoveGraphics.setCanvas(canvas)
	-- LoveGraphics.clear()
	-- LoveGraphics.setColor(0.5, 0.5, 0.5, 1)
	-- LoveGraphics.rectangle("fill", 0, 0, Graphics.ScreenSize.x, Graphics.ScreenSize.y)
	-- LoveGraphics.setColor(1, 1, 1, 1)
	-- LoveGraphics.push()
	-- 	LoveGraphics.scale(Graphics.ScreenToRenderRatio.x, Graphics.ScreenToRenderRatio.y)
	-- 	LoveGraphics.translate(Graphics.ScreenSize.x / 2, Graphics.ScreenSize.y / 2)
	-- 	-- LoveGraphics.setWireframe(true)
		Graphics:updateInterpolate(Run.accum)
	-- 	-- Graphics.processQueue()
		Graphics:draw()
	-- 	-- LoveGraphics.setWireframe(false)
	-- LoveGraphics.pop()
	-- LoveGraphics.setCanvas()
	-- -- print(Graphics.RenderToScreenRatio, Graphics.ScreenToRenderRatio)
	-- -- LoveGraphics.translate(720 * Graphics.ScreenToRenderRatio.x / 2, 1)
	-- local sx, sy = Graphics.RenderToScreenRatio.x, Graphics.RenderToScreenRatio.y
	-- LoveGraphics.draw(canvas, 0, 0, 0, sx, sy, 0, 0)
	-- -- LoveGraphics.draw(canvas, 50, 50, 0, 1, 1, 0, 0)

	Graphics.UI.Immediate.Draw(Run.G_RENDER_DT)

	debugDraw()

	local endTime = getTime()

	Run.G_RENDER_DT = endTime - startTime

	Run.G_RENDER_TIME = Run.G_RENDER_TIME + (Run.G_RENDER_DT - Run.G_RENDER_TIME) * (1 - Run.G_RENDER_TIME_SMOOTHNESS)

	Run.G_RENDER_TIME_PERCENT_FRAME = Run.G_RENDER_TIME / (Run.rate) * 100

	--[[
	local f = 60
	acc = acc + Run.G_RENDER_DT * f
	while acc > 1 / 60 do
		updateRender(acc)
		acc = acc - 1 / 60
	end
	--]]
end
function love.quit()
end

Util.Debug.PRINT_ENV(_G, false)

printf("\n")
Log.log("Exiting run.lua\n")
