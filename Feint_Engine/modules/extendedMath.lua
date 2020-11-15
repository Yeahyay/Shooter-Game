local extendedMath = {}

function extendedMath.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function extendedMath.findAngleDifference(from, to)
	return math.asin(math.sin(from) * math.cos(to) - math.cos(from) * math.sin(to))
end

function extendedMath.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function extendedMath.clamp(x, min, max)
	min = min or - math.huge
	max = max or math.huge
	if (x < min) then
		x = min
	elseif (x > max) then
		x = max
	end
	return x
end

local util = Feint.Util.Core
function extendedMath.oscillate(amplitude, rate, offset)
	return (math.cos(util.getTime() * rate + offset) * 0.5 + 0.5) * amplitude
end
function extendedMath.oscillateSigned(amplitude, rate, offset)
	return math.cos(util.getTime() * rate + offset) * amplitude
end

function extendedMath.random2(a, b, c)
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

function extendedMath.random3(a, b, c)
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

function extendedMath.sinRange(x, min, max)
	local range = max - min
	return ((math.sin(x) + 1) / 2) * range
end

function extendedMath.cosRange(x, min, max)
	local range = max - min
	return ((math.cos(x) + 1) / 2) * range
end

return extendedMath
