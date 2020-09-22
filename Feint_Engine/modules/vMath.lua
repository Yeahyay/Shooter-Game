local vMath = {}
-- vMath.Vec2 = require(Feint.Paths.Lib.."brinevector2D/brinevector")
-- vMath.Vec3 = require(Feint.Paths.Lib.."brinevector3D/brinevector3D")
setmetatable(vMath, {
	__tostring = function()
		return "vMath"
	end
})


-- function vMath:relativeToAbsolute(a, to)
-- 	assert(Vec2.isVector(a), "ARGUMENT 1 IS NOT A VECTOR")
-- 	assert(Vec2.isVector(to) or to == nil, "ARGUMENT 2 IS NOT A VECTOR")
-- 	return a % (to or screenSize)
-- end
-- function vMath:absoluteToRelative(a, to)
-- 	return a / (to or screenSize)
-- end
-- function vMath:relativeToScreen(a)
-- 	return self:absoluteToScreen(self:relativeToAbsolute(a))
-- end
-- function vMath:absoluteToScreen(a)
-- 	return a - screenSize / 2
-- end
-- function vMath:screenToRelative(a)
-- 	return self:absoluteToRelative(self:screenToAbsolute(a))
-- end
-- function vMath:screenToAbsolute(a)
-- 	return a + screenSize / 2
-- end

function vMath:vec2ToVec3(pos, y)
	return self.Vec3(pos.x, y or 1, pos.y)
end
function vMath:vec3ToVec2(pos)
	return self.Vec2(pos.x, pos.z)
end
function vMath:worldToScreen(pos)
	return self.Vec2(pos.x, pos.y + pos.z)
end

function vMath:rotateVec2(pos, angle)
	local nx = pos.x * math.cos(angle.y) - pos.y * math.sin(angle.y)
	local ny = pos.x * math.sin(angle.y) + pos.y * math.cos(angle.y) * math.cos(angle.x)
	return self.Vec2(nx, ny)
end
function vMath:rotateVec3(pos, angle)
	local nx = pos.x * math.cos(angle.y) - pos.z * math.sin(angle.y)
	local ny = (pos.x * math.sin(angle.y) + pos.z * math.cos(angle.y)) * math.cos(angle.x)
	return self.Vec3(nx, pos.y, ny)
end

return vMath
