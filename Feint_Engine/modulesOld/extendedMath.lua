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
	return math.max(math.min(min, x), max)
end

local util = Feint.Core.Util
function extendedMath.oscillateManual(time, amplitude, rate, offset)
	return (math.cos(time * rate + offset) * 0.5 + 0.5) * amplitude
end
function extendedMath.oscillateManualSigned(time, amplitude, rate, offset)
	return math.cos(time * rate + offset) * amplitude
end
function extendedMath.oscillate(amplitude, rate, offset)
	return extendedMath.oscillateManual(util.getTime(), amplitude, rate, offset)
end
function extendedMath.oscillateSigned(amplitude, rate, offset)
	return extendedMath.oscillateManualSigned(util.getTime(), amplitude, rate, offset)
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
