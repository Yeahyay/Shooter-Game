local DataStructures = {
	depends = {"Math", "Core.Paths", "Core.AssetManager"},
	isThreadSafe = false,
}

local ffi = require("ffi")

function DataStructures:load(isThread)
	if not isThread then
		require("love.window")
	end
	-- require("love.DataStructures")

	local Paths = Feint.Core.Paths

	Paths:Add("DataStructures", Paths.Core .. "DataStructures")

	self.Stack = require(Paths.DataStructures .. "Stack")
	self.FSM = require(Paths.DataStructures .. "FiniteStateMachine")
	self.FSM2 = require(Paths.DataStructures .. "FiniteStateMachine2")
	self.BinaryHeap = require(Paths.DataStructures .. "BinaryHeap")
	self.PriorityQueue = require(Paths.DataStructures .. "PriorityQueue")
end

return DataStructures
