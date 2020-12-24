local extendedMath = {
	depends = {"Core.Paths"}
}

function extendedMath:load()
	Feint.Core.Paths.Add("Math", Feint.Core.Paths.Modules .. "math")

	self.Vec2 = require(Feint.Core.Paths.Lib .. "brinevector2D.brinevector")
	self.Vec3 = require(Feint.Core.Paths.Lib .. "brinevector3D.brinevector3D")
	-- Feint.vMath = require(Feint.Core.Paths.Root .. "vMath")
	self.G_INF = math.huge
	self.G_SEED = 2--love.timer.getTime())

	function self.round(num, numDecimalPlaces)
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	function self.findAngleDifference(from, to)
		return math.asin(math.sin(from) * math.cos(to) - math.cos(from) * math.sin(to))
	end

	function self.round(num, numDecimalPlaces)
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	function self.clamp(x, min, max)
		return math.max(math.min(min, x), max)
	end

	local util = Feint.Core.Util
	function self.oscillateManual(time, amplitude, rate, offset)
		return (math.cos(time * rate + offset) * 0.5 + 0.5) * amplitude
	end
	function self.oscillateManualSigned(time, amplitude, rate, offset)
		return math.cos(time * rate + offset) * amplitude
	end
	function self.oscillate(amplitude, rate, offset)
		return self.oscillateManual(util.getTime(), amplitude, rate, offset)
	end
	function self.oscillateSigned(amplitude, rate, offset)
		return self.oscillateManualSigned(util.getTime(), amplitude, rate, offset)
	end

	function self.random2(a, b, c)
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

	function self.random3(a, b, c)
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

	function self.sinRange(x, min, max)
		local range = max - min
		return ((math.sin(x) + 1) / 2) * range
	end

	function self.cosRange(x, min, max)
		local range = max - min
		return ((math.cos(x) + 1) / 2) * range
	end
end

return extendedMath
