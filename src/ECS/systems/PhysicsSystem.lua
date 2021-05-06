-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math
local random2 = fmath.random2

local PhysicsSystem = System:new("PhysicsSystem")
function PhysicsSystem:init(...)
end

function PhysicsSystem:start(EntityManager)
	EntityManager:forEachNotParallel("PhysicsSystem_start", function()
		local function execute(Entity, Physics, Transform)
			Physics.accelerationX = 10
			Transform.x = fmath.random2(-Feint.Core.Graphics.ScreenSize.x * 0.5, Feint.Core.Graphics.ScreenSize.x * 0.5)
			Transform.y = fmath.random2(-Feint.Core.Graphics.ScreenSize.y * 0.5, Feint.Core.Graphics.ScreenSize.y * 0.5)
		end
		return execute
	end)
end

local function sign(x)
	return x > 0 and 1 or x < 0 and -1 or 0
end

function PhysicsSystem:update(EntityManager, dt)
	local time = Feint.Core.Time:getTime()
	dt = 1 / 60
	EntityManager:forEachNotParallel("PhysicsSystem_update", function()
			-- local pi = math.pi
			local execute = function(Entity, Physics, Transform)
				Physics.positionXOld = Transform.x
				Physics.positionYOld = Transform.y

				local posX, posY = Transform.x, Transform.y
				local lastPosX, lastPosY = Physics.positionXOld, Physics.positionYOld
				-- local velX, velY = Physics.velocityX, Physics.velocityY
				local accX, accY = Physics.accelerationX, Physics.accelerationY
				accX = accX - accX * Physics.drag
				accY = accY - accY * Physics.drag
				Physics.accelerationX, Physics.accelerationY = math.min(accX, Physics.accelerationCapX), math.min(accY, Physics.accelerationCapY)

				-- print(accX, accY, dt * dt, accX * dt * dt)

				local velX = posX - lastPosX
				local velY = posY - lastPosY

				local nextPosX = posX + velX + accX * (dt * dt) * 100
				local nextPosY = posY + velY + accY * (dt * dt) * 100

				Transform.x = nextPosX
				Transform.y = nextPosY
			end
			return execute
		end
	)
end

return PhysicsSystem
