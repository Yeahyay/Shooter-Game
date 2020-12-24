Feint_INPUT_PATH = ...

Feint_InputContext = require(Feint_INPUT_PATH.."/InputContext", true)

-- local input_up				= Feint_InputCommand:new("up",		{{"key",		"w", "up"}},		true, true, true)
-- local input_down			= Feint_InputCommand:new("down",		{{"key",		"s", "down"}},		true, true, true)
-- local input_left			= Feint_InputCommand:new("left",		{{"key",		"a", "left"}},		true, true, true)
-- local input_right			= Feint_InputCommand:new("right",	{{"key",		"d", "right"}},	true, true, true)
-- local input_alternate	= Feint_InputCommand:new("m2",		{{"mouse",	"2"}},				true, true, true)
-- local input_fire			= Feint_InputCommand:new("m1",		{{"mouse",	"1"}},				true, true, true)
--
-- local input_aim			= Feint_InputCommand:new("mouse",	{{"mouse",	"MOVE"}},			true, true, true)

-- local function mouseStart(values, vectors)
-- 	local mouse = InputSystem:getMouse()
-- 	mouse.ClickPosition = mouse.Position
-- 	mouse.ClickPositionWorld = mouse.PositionWorld
-- end
-- local function mouseStop(values, vectors)
-- 	local mouse = InputSystem:getMouse()
-- 	mouse.ReleasePosition = mouse.Position
-- 	mouse.ReleasePositionWorld = mouse.PositionWorld
-- end
--
-- function input_fire:start(...)
-- 	mouseStart(...)
-- end
-- function input_fire:stop(...)
-- 	mouseStop(...)
-- end
-- function input_alternate:start(...)
-- 	mouseStart(...)
-- end
-- function input_alternate:stop(...)
-- 	mouseStop(...)
-- end

-- PRINT_ENV(_ENV_LAST, false)

local InputSystem = System:new("InputSystem", {"input", Input})
function InputSystem:init(...)
	self.active = 0
	self.contexts = Stack()
	self.contexts:push(Feint_InputContext:new("Mouse"))

	local context = self.contexts:peek()

	context:addInput("m2",		{{"mouse",	"2"}},				true, true, true)
	context:addInput("m1",		{{"mouse",	"1"}},				true, true, true)
	context:addInput("mouse",	{{"mouse",	"MOVE"}},			true, true, true)

	self.contexts:push(Feint_InputContext:new("Movement"))
	local context = self.contexts:peek()

	context:addInput("up",		{{"key",		"w", "up"}},		true, true, true)
	context:addInput("down",	{{"key",		"s", "down"}},		true, true, true)
	context:addInput("left",	{{"key",		"a", "left"}},		true, true, true)
	context:addInput("right",	{{"key",		"d", "right"}},	true, true, true)

	self.mouse = {
		PositionRawOld = vMath.Vec2(0, 0);
		PositionRaw = vMath.Vec2(0, 0);
		PositionUnitRawOld = vMath.Vec2(0, 0);
		PositionUnitRaw = vMath.Vec2(0, 0);

		PositionOld = vMath.Vec2(0, 0);
		Position = vMath.Vec2(0, 0);
		PositionUnitOld = vMath.Vec2(0, 0);
		PositionUnit = vMath.Vec2(0, 0);

		PositionDeltaRawOld = vMath.Vec2(0, 0);
		PositionDeltaRaw = vMath.Vec2(0, 0);
		PositionDeltaOld = vMath.Vec2(0, 0);
		PositionDelta = vMath.Vec2(0, 0);


		PositionWorldRawOld = vMath.Vec3(0, 0, 0);
		PositionWorldRaw = vMath.Vec3(0, 0, 0);

		PositionWorldOld = vMath.Vec3(0, 0, 0);
		PositionWorld = vMath.Vec3(0, 0, 0);

		PositionWorldDeltaOld = vMath.Vec3(0, 0, 0);
		PositionWorldDelta = vMath.Vec3(0, 0, 0);


		ClickPosition = vMath.Vec2(0, 0);
		ClickPositionWorld = vMath.Vec3(0, 0, 0);

		ReleasePosition = vMath.Vec2(0, 0);
		ReleasePositionWorld = vMath.Vec3(0, 0, 0);

		Colliding = false;
		CollisionSize = vMath.Vec3(4, 4, 4);
	}
	self.mouse.Default = {
		"PositionRaw";
		"PositionUnitRaw";
		"Position";
		"PositionUnit";
		"PositionDelta";
		"PositionWorld";
		"ClickPosition";
		"ClickPositionWorld";
		"ReleasePosition";
		"ReleasePositionWorld";
	}
end
function InputSystem:getMouse()
	return self.mouse
end
function InputSystem:update(dt)
	if self.active > 0 then
		if not self.contexts:empty() then
			-- self.contexts.current:handleInput(self.mouse)
			self.contexts:peek():handleInput(self.mouse)
		end
	else
		self.active = self.active + 1
	end
end
function InputSystem:mousepressed(x, y, button, istouch, presses)
	self.active = 1
end
function InputSystem:mousereleased(x, y, button, istouch, presses)
	self.active = -1
end
function InputSystem:mousemoved(x, y, dx, dy, istouch)
	if dx ~= 0 or dy ~= 0 then
		self.active = 1
	else
		self.active = -1
	end
end
function InputSystem:keypressed(key, scancode, isrepeat)
	self.active = 1
	-- inputScheme:updateRawInput(key, "input", "key", 1, nil)
end
function InputSystem:keyreleased(key, scancode)
	self.active = -1
	-- inputScheme:updateRawInput(key, "input", "key", 0, nil)
end

return InputSystem
