printf("Entering DefaultWorld.lua\n\n")

PRINT_ENV(_ENV, true)

coreUtil.logLevel = 1

-- INIT ASSETS
--[[
do
	-- 	require("systems/AssetManagerSystem")
	AssetManager:addAsset("Image", "TestTexture1", love.graphics.newImage("sprites/Test Texture 1.png"))
	AssetManager:addAsset("Image", "PlayerImage", love.graphics.newImage("sprites/walking1.png"))
	AssetManager:addAsset("Image", "EnemyImage", love.graphics.newImage("sprites/enemy 1 walking 1.png"))

	AssetManager:addAsset("SpriteBatch", "PlayerSpriteBatch",
		love.graphics.newSpriteBatch(
			AssetManager:requestAsset("Image", "PlayerImage"),
			1000,
			"dynamic"
		)
	)
end
--]]

-- currentWorld = Instance:new("DefaultWorld")

-- currentWorld = PhysicsWorld

love.physics.setMeter(64)
DEFAULT_PHYSICS_WORLD = love.physics.newWorld(0, 9.80665 * 64, true)

-- local function newComponent(instance, name, ...)
-- 	local component = require(ECS_PATH.."components/"..name.."Component", true)
-- 	instance:newComponent(component)
-- 	return component
-- end
-- local function newSystem(instance, name, ...)
-- 	local systemName = name.."System"
-- 	local system = require(ECS_PATH.."systems/"..systemName, true)
-- 		:instantiate(systemName.."Instance", ...)
-- 	instance:newSystem(system)
-- 	return system
-- end

--[[
if currentWorld then
	currentWorld:newEvent("update")
	currentWorld:newEvent("draw")

	currentWorld:newEvent("keypressed")
	currentWorld:newEvent("keyreleased")
	currentWorld:newEvent("mousemoved")
	currentWorld:newEvent("mousepressed")
	currentWorld:newEvent("mousereleased")

	currentWorld:listen(AssetManager, "update", "update")
	currentWorld:listen(AssetManager, "draw", "draw")
end
--]]

--[[
-- COMPONENTS
if currentWorld then
	Renderer = newComponent(currentWorld, "Renderer")
	Transform = newComponent(currentWorld, "Transform")
	Physics = newComponent(currentWorld, "Physics")
	Camera = newComponent(currentWorld, "Camera")
	Input = newComponent(currentWorld, "Input")
end
--]]

--[[
-- SYSTEMS
if true and currentWorld then
	-- RENDER
	RenderSystem = newSystem(currentWorld, "Render")
	currentWorld:listen(RenderSystem, "update", "update")
	currentWorld:listen(RenderSystem, "draw", "draw")

	-- PHYSICS
	PhysicsSystem = newSystem(currentWorld, "Physics", DEFAULT_PHYSICS_WORLD)
	currentWorld:listen(PhysicsSystem, "update", "update")

	-- INPUT
	InputSystem = newSystem(currentWorld, "Input")
	currentWorld:listen(InputSystem, "update", "update")
	currentWorld:listen(InputSystem, "keypressed", "keypressed")
	currentWorld:listen(InputSystem, "keyreleased", "keyreleased")
	currentWorld:listen(InputSystem, "mousemoved", "mousemoved")
	currentWorld:listen(InputSystem, "mousepressed", "mousepressed")
	currentWorld:listen(InputSystem, "mousereleased", "mousereleased")

	-- CAMERA
	CameraSystem = newSystem(currentWorld, "Camera")
	currentWorld:newEvent("viewTransform")
	currentWorld:listen(CameraSystem, "viewTransform", "viewTransform")
end
--]]

-- currentWorld:update()

-- local entity = currentWorld:createNewEntity{Renderer, Transform, Camera}
-- currentWorld:setComponentData(entity, Transform, function(self)
-- 	self.position = vMath.Vec3(0, 0, 0)
-- 	self.size = vMath.Vec3(500, 10, 500)
-- end)
-- currentWorld:setComponentData(entity, Camera, function(self)
-- 	self.zoom = 1
-- end)
--
-- local entity = currentWorld:createNewEntity{Renderer, Transform, Physics}
-- currentWorld:setComponentData(entity, Transform, function(self)
-- 	self.position = vMath.Vec3(0, 0, 50-G_SCREEN_SIZE.y/2)
-- 	self.size = vMath.Vec3(G_SCREEN_SIZE.x*2, 10, 100)
-- end)
-- currentWorld:setComponentData(entity, Physics, function(self)
-- 	self.world = DEFAULT_PHYSICS_WORLD
-- 	self.type = "static"
-- 	-- self.sensor = true
-- end)

function load()
	-- INIT VARIABLES
	INITMODE = "Edit"

	pause = false

	-- INIT LOVE2D SETINGS
	do
		love.mouse.setVisible(true)
		--love.mouse.setRelativeMode(true)
		--love.mouse.setCursor()
		--love.audio.setDistanceModel("linear")

		-- print(love.filesystem.getIdentity())

		--print(love.filesystem.createDirectory("saves"))
		-- love.graphics.setLineStyle("rough")
		--love.graphics.setWireframe(true)
		love.graphics.setDefaultFilter("nearest", "nearest", 16)
		love.window.setMode(G_SCREEN_SIZE.x, G_SCREEN_SIZE.y, {fullscreen = false, vsync = false, resizable = true, minwidth = 32, minheight = 18, msaa = 4})
		-- love.graphics.setFont(fonts.SourceSansProRegular)

		love.joystick.loadGamepadMappings(Feint_LIB_PATH.."gamecontrollerdb.txt")

		love.audio.setVolume(0.125)
		love.audio.setEffect("reverb", {type = "reverb",
			gain = 0.55,
			highgain = 1,
			density = 0.6,
			decayhighratio = 1.0,
			diffusion = 0.6,
			decaytime = 1.75,
		})
	end
end
function update(dt)
	-- if not pause then
	-- 	currentWorld:dispatch("update", dt)
	-- end
end
function draw()
	love.graphics.setBackgroundColor(0.2, 0.2, 0.2, 1)
	love.graphics.push()

	love.graphics.translate(G_SCREEN_SIZE.x / 2, G_SCREEN_SIZE.y / 2)
	-- currentWorld:dispatch("viewTransform")
	-- currentWorld:dispatch("draw", dt)

	love.graphics.pop()
end

function keypressed(key, scancode, isrepeat)
	if key == "escape" then
		pause = not pause
	end
	-- currentWorld:dispatch("keypressed", key, scancode, isrepeat)
end
function keyreleased(key, scancode, isrepeat)
	-- currentWorld:dispatch("keyreleased", key, scancode, isrepeat)
end

function mousemoved(...)
	-- currentWorld:dispatch("mousemoved", ...)
end

function mousepressed(...)
	-- currentWorld:dispatch("mousepressed", ...)
end
function mousereleased(...)
	-- currentWorld:dispatch("mousereleased", ...)
end

local initTrue = true
function gui(dt)
	--[[
	local delta = love.timer.getAverageDelta()
	local frameTime = love.timer.getDelta()
	local stats = love.graphics.getStats()

	-- local hover = mouse:getHover()

	local entityManager = currentWorld.entityManager

	Slab.BeginWindow('Debug Window', {
		X = 0,
		Y = 0,
		Title = "Debug Window",
		AllowMove = false,
		-- AutoSizeWindow = false,
		-- AutoSizeContent = false,
		-- AllowResize = true,
		-- ResetSize = true,
	})
	Slab.Text(string.format("ID INDEX: %d", entityManager.ID_INDEX))
	if Slab.BeginTree("Rendering", {IsOpen = initTrue}) then
		Slab.BeginTree(FPS, {IsLeaf = true})
		Slab.BeginTree(string.format("Average frame time: %.3f ms", 1000 * delta), {IsLeaf = true})
		Slab.BeginTree(string.format("Frame time: %.3f ms", 1000 * frameTime), {IsLeaf = true})
		Slab.BeginTree(string.format("Memory usage: %.3f mb", collectgarbage("count") / 1024), {IsLeaf = true})
		Slab.BeginTree(string.format("Draw calls: %d", RENDERSTATS.drawcalls), {IsLeaf = true})

		Slab.EndTree()
	end
	Slab.Separator()
	if Slab.BeginTree("Mouse", {IsOpen = false}) then
		local mouse = InputSystem:getMouse()
		for _, attribute in pairs(mouse.Default) do
			Slab.BeginTree(string.format("%s: %s", attribute, mouse[attribute]), {IsLeaf = true})
		end

		Slab.EndTree()
	end
	if InputSystem then
	if Slab.BeginTree("Inputs", {IsOpen = initTrue}) then
		for _, context in InputSystem.contexts:pairs() do
			-- local inputs = InputSystem.contexts:peek().inputs.values
			local inputs = context.inputs.values
			if Slab.BeginTree(string.format("%s", context.name), {IsLeaf = false}) then
				for _, key in pairs(inputs) do
					Slab.BeginTree(string.format("%s (%s): %s", key.name, key.state, key.values[1]), {IsLeaf = true})
				end

				Slab.EndTree()
			end

			local t = Slab.BeginTree(string.format("%s", context.name), {IsLeaf = true})
			if t then
				Slab.EndTree()
			end
		end

		Slab.EndTree()
	end
	end

	Slab.EndWindow()

	Slab.SetScrollSpeed(24)

	Slab.BeginWindow('Systems Window', {
		X = G_SCREEN_SIZE.x - G_SCREEN_SIZE.x/4 - 4;
		Y = 0;
		W = G_SCREEN_SIZE.x/4;
		H = G_SCREEN_SIZE.y/2;
		Title = "Systems View";
		AllowMove = true;
		AutoSizeWindow = false;
		-- AutoSizeContent = false,
		AllowResize = true,
		-- ResetSize = true,
	})
	if Slab.BeginTree("Systems", {IsOpen = initTrue}) then
		-- for each system
		for index, system in ipairs(currentWorld.systems) do
			if Slab.BeginTree(string.format("%s: %s", index, system.data.Name), {IsOpen = false}) then
				local iter = 0
				-- for every filter in the system
				for filterName, filterData in pairs(system.data.filters) do

					local filterTree = Slab.BeginTree(string.format("%s", filterName), {IsOpen = initTrue})
					if filterTree then
						if Slab.BeginTree("Components", {IsOpen = false}) then
							for _, component in ipairs(filterData) do
								Slab.BeginTree(string.format("%s: %s", _, component.Name), {IsLeaf = true})
							end

							Slab.EndTree()
						end

						-- for k, v in pairs(filterData) do
						-- 	for k, v in pairs(v) do
						-- 		print(k, v, "sdkfms")
						-- 	end
						-- end
						for entity, index in pairs(filterData) do
							-- local components = system.entities.values[index]
							Slab.BeginTree(string.format("entity %s %s", entity, index.Name), {IsLeaf = true})
							-- for k, v in pairs(index) do
							-- 	Slab.BeginTree(string.format("%s %s", k, v), {IsLeaf = true})
							-- end
							-- if index > 10 then break end
						end

						Slab.EndTree()
					end
				end
				-- Slab.BeginTree(string.format("%s: %s", iter, system.components.size), {IsLeaf = true})

				Slab.EndTree()
			end
		end

		Slab.EndTree()
	end
	Slab.EndWindow()
	--]]

	initTrue = false
end
function quit()
	if PROFILER then
		print("QUITTING")
		local PROFILER_OUT = io.open("Profile", "w")
		PROFILER:stop()
		PROFILER:report(PROFILER_OUT, true)
		PROFILER_OUT:close()
	end
	return false
end

-- CONSOLE
do
	function love.textinput(text)
		if (text == "`") then console.Show() end
	end
end

PRINT_ENV(_ENV, false)

printf("\nExiting Game1.lua\n\n")
