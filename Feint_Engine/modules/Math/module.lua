local extendedMath = {
	depends = {"Core.Paths"}
}

function extendedMath:load()
	require("love.math")

	Feint.Core.Paths:Add("Math", Feint.Core.Paths.Modules .. "math")

	self.Vec2 = require(Feint.Core.Paths.Lib .. "brinevector2D.brinevector")
	self.Vec3 = require(Feint.Core.Paths.Lib .. "brinevector3D.brinevector3D")
	-- Feint.vMath = require(Feint.Core.Paths.Root .. "vMath")
	self.G_INF = math.huge
	self.G_SEED = 2--love.timer.getTime())

	function self:getDigits(number)
		return math.floor(math.log10(number) + 1)
	end

	local sin = math.sin
	local cos = math.cos
	function self.round(num, numDecimalPlaces)
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	function self.findAngleDifference(from, to)
		return math.asin(sin(from) * cos(to) - cos(from) * sin(to))
	end

	function self.round(num, numDecimalPlaces)
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	function self.clamp(x, min, max)
		return math.max(math.min(min, x), max)
	end

	local util = Feint.Core.Util
	function self.oscillateManual(theta, amplitude, rate, offset)
		return (cos(theta * rate + offset) * 0.5 + 0.5) * amplitude
	end
	function self.oscillateManualSigned(theta, amplitude, rate, offset)
		return cos(theta * rate + offset) * amplitude
	end
	function self.oscillate(amplitude, rate, offset)
		return self.oscillateManual(util.getTime(), amplitude, rate, offset)
	end
	function self.oscillateSigned(amplitude, rate, offset)
		return self.oscillateManualSigned(util.getTime(), amplitude, rate, offset)
	end

	function self.triangle(theta, amplitude, rate, offset)
		return ((math.asin(math.cos(theta * rate + offset)) / (math.pi * 0.5))) * amplitude
	end

	local random = love.math.random
	function self.random2(a, b, c)
		local ans
		if b then
			a = a or 1
			b = b or 1
			ans = a + ((b - a) * ((random() * 1) - 0))
		else
			a = a or 1
			ans = a * ((random() * 2) - 1)
		end
		return ans
	end

	function self.random3(a, b, c)
		local ans
		if b then
			a = a or 1
			b = b or 1
			ans = a + ((b - a) * ((random() * 1) - 0))
		else
			a = a or 1
			ans = a * ((random() * 2) - 1)
		end
		return ans
	end

	function self.sinRange(x, min, max)
		local range = max - min
		return ((sin(x) + 1) / 2) * range
	end

	function self.cosRange(x, min, max)
		local range = max - min
		return ((cos(x) + 1) / 2) * range
	end
end

return extendedMath
