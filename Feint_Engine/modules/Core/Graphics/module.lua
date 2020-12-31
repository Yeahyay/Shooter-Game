local graphics = {
	-- depends = {"Math"}
}

function graphics:load()
	self.drawables = {}
	function self:addDrawable(type, ...)
		if type == "rect" then
			self:addRectangle(...)
		end
	end

	function self:addRectangle(mode, x, y, r, width, height)

	end
end

return graphics
