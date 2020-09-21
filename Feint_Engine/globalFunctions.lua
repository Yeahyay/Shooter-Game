io.stdout:setvbuf("no")
--[[Vector2 = require("lib/brinevector2D/brinevector")
Vector3 = require("lib/brinevector3D/brinevector3D")
--Matrix = require("lib/lua-matrix-master/lua/matrix")
class = require("lib/30log-clean")]]

--[[original_type = type
function type(obj)
	local otype = original_type(obj)
	if otype == "table" and obj.Type then
		return obj.Type
	end
	return otype
end]]

function FindAngleDifference(from, to)
	return math.asin(math.sin(from) * math.cos(to) - math.cos(from) * math.sin(to))
end
--
-- function vec2ToVec3(pos, y)
-- 	return Vector3.new(pos.x, y or 1, pos.y)
-- end
-- function vMath:vec3ToVec2(pos)
-- 	return Vector2.new(pos.x, pos.y + pos.z)
-- end
--
-- function rotateVec2(pos, angle)
-- 	local nx = pos.x * math.cos(angle.y) - pos.y * math.sin(angle.y)
-- 	local ny = pos.x * math.sin(angle.y) + pos.y * math.cos(angle.y) * math.cos(angle.x)
-- 	return Vector2.new(nx, ny)
-- end
-- function rotateVec3(pos, angle)
-- 	local nx = pos.x * math.cos(angle.y) - pos.z * math.sin(angle.y)
-- 	local ny = (pos.x * math.sin(angle.y) + pos.z * math.cos(angle.y)) * math.cos(angle.x)
-- 	return Vector3.new(nx, pos.y, ny)
-- end

function math.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.random2(a, b, c)
	local ans
	if b then
		a = a or 1
		b = b or 1
		ans = a + ((b - a) * ((love.math.random() * 1) - 0))
	else
		a = a or 1
		ans = a * ((love.math.random() * 2) - 1)
	end
	return ans
end

function math.random3(a, b, c)
	local ans
	if b then
		a = a or 1
		b = b or 1
		ans = a + ((b - a) * ((love.math.random() * 1) - 0))
	else
		a = a or 1
		ans = a * ((love.math.random() * 2) - 1)
	end
	return ans
end

function math.sin2(a)
	return (math.sin(a) + 1) / 2
end

function math.cos2(a)
	return (math.cos(a) + 1) / 2
end

function math.powerOfTwo(a)
	--return (a ~= 0) and ((a & (a-1))==0)
end

function math.clamp(x, min, max)
	min = min or - math.huge
	max = max or math.huge
	if (x < min) then
		x = min
	elseif (x > max) then
		x = max
	end
	return x
end

function string.firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

function deepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
