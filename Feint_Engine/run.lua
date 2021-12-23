-- CORE FILE

-- direct requires (BAD BUT EASY)
-- luacheck: push ignore
local ffi = require("ffi")
local cute = require("Cute-0_4_0.cute")
-- local fpsGraph = require("Feint_Engine.lib.FPSGraph")

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

local running = true

-- luacheck: pop

function love.keypressed(key, scancode, isrepeat)
	cute.keypressed(key, scancode, isrepeat)
	if key == "space" then
		running = true
	end
	Feint.Callbacks.Keyboard.Pressed(key, scancode, isrepeat)
end
function love.keyreleased(key, scancode)
	Feint.Callbacks.Keyboard.Released(key, scancode)
end
function love.mousemoved(x, y, dx, dy)
	Feint.Callbacks.Mouse.Moved(x, y, dx, dy)
end

function love.joystickadded(joystick)
	print("ADDED", joystick)
	Feint.Callbacks.Joystick.Added(joystick)
end
function love.joystickremoved(joystick)
	print("REMOVED", joystick)
	Feint.Callbacks.Joystick.Removed(joystick)
end
function love.gamepadaxis(joystick, axis, value)
	Feint.Callbacks.Gamepad.Axis(joystick, value)
end
function love.gamepadpressed(joystick, button)
	Feint.Callbacks.Gamepad.Pressed(joystick, button)
end
function love.gamepadreleased(joystick, button)
	Feint.Callbacks.Gamepad.Released(joystick, button)
end
function love.joystickhat(joystick, hat, direction)
	Feint.Callbacks.Joystick.Hat(joystick, hat, direction)
end
function love.joystickaxis(joystick, axis, value)
	Feint.Callbacks.Joystick.Axis(joystick, axis, value)
end
function love.joystickpressed(joystick, button)
	Feint.Callbacks.Joystick.Pressed(joystick, button)
end
function love.joystickreleased(joystick, button)
	Feint.Callbacks.Joystick.Released(joystick, button)
end


function love.mousepressed(x, y, button, isTouch)
	Feint.Callbacks.Mouse.Pressed(x, y, button, isTouch)
end
function love.mousereleased(x, y, button, isTouch)
	Feint.Callbacks.Mouse.Released(x, y, button, isTouch)
end

function love.threaderror(thread, message)
	Feint.Callbacks.Gneral.threaderror(thread, message)
end
function love.resize(x, y)
	Feint.Callbacks.Window.resize(x, y)
end

function love.load(arg, unfilteredArg)
	local testing = false
	for k, v in pairs(arg) do
		if v == "--tests" then
			testing = true
		end
	end
	if testing then
		cute.setKeys("h", "down", "up")
		cute.go{"--cute"}
	else
		Feint.Callbacks.General.Load(arg, unfilteredArg)
		local status, message = pcall(Feint.Callbacks.General.Load, arg, unfilteredArg)
		if not status then
			running = false
			printf("FEINT LOAD ERROR: %s\n", message)
		end
	end
end

function love.update(dt)
	if Feint.loaded and running then
		local status, message = pcall(Feint.Callbacks.General.Update, dt)
		if not status then
			running = false
			printf("FEINT UPDATE ERROR: %S\n", message)
		end
	end
end

local function updateRender(dt) -- luacheck: ignore
end
local font = love.graphics.newFont()
function love.draw()
	if Feint.loaded and running then
		local status, message = pcall(Feint.Callbacks.General.Draw, nil)
		if not status then
			running = false
			printf("FEINT DRAW ERROR: %s\n", message)
		end
	end
	love.graphics.setFont(font)
	cute.draw()
end
function love.quit()
end

Debug.PRINT_ENV(_G, false)

printf("\n")
Log.log("Exiting run.lua\n")
