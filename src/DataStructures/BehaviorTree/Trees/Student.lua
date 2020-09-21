
--GameInstance:addSystem(behaviorSystem, "draw", "postDraw", true)

--[[local mouseBottomLeft = behaviorSystem:newTree("mouseBottomLeft")
mouseBottomLeft.Position = Vector2.new(1000, 0)
local mComp1 = mouseBottomLeft:addComposite("dank1", Sequence)
	mouseBottomLeft:addLeaf("mouseX < 0", Leaf, mComp1, 0, function() if mouse.Position.x < 0 then return "Success" end return "Failure" end)
	mouseBottomLeft:addLeaf("mouseY < 0", Leaf, mComp1, {}, function() if mouse.Position.y < 0 then return "Success" end return "Failure" end)]]

--print("wergokinsegepoin")

local moveTowards = behaviorSystem:newTree("moveTowards")
--moveTowards.Position = Vector2.new(750, 0)
	local move = moveTowards:addComposite("up", Selector)
		local up = moveTowards:addComposite("up", Selector, move)
		local moveUp = moveTowards:addLeaf("isTargetAbove", Leaf, up, nil,
			function(vars, student)
				local body = student:get(Body)
				local position = body.Position
				local behavior = student:get(Behavior)
				if body.Position.y < behavior.TargetPosition.y then
					GameInstance:emit("up", student)
				end
				return "Failure"
			end)
		local down = moveTowards:addComposite("down", Selector, move)
		local moveDown = moveTowards:addLeaf("isTargetBelow", Leaf, down, nil,
			function(vars, student)
				local body = student:get(Body)
				local position = body.Position
				local behavior = student:get(Behavior)
				if body.Position.y > behavior.TargetPosition.y then
					GameInstance:emit("down", student)
				end
				return "Failure"
			end)
			local left = moveTowards:addComposite("left", Selector, move)
			local moveLeft = moveTowards:addLeaf("isTargetLeft", Leaf, left, nil,
				function(vars, student)
					local body = student:get(Body)
					local position = body.Position
					local behavior = student:get(Behavior)
					if body.Position.x > behavior.TargetPosition.x then
						GameInstance:emit("left", student)
					end
					return "Failure"
				end)
			local right = moveTowards:addComposite("right", Selector, move)
			local moveRight = moveTowards:addLeaf("isTargetLeft", Leaf, right, nil,
				function(vars, student)
					local body = student:get(Body)
					local position = body.Position
					local behavior = student:get(Behavior)
					if body.Position.x < behavior.TargetPosition.x then
						GameInstance:emit("right", student)
					end
					return "Failure"
				end)

local StudentBehavior = behaviorSystem:newTree("Student")
local composite1 = StudentBehavior:addComposite("foo1", Sequence)
--[[local composite2 = StudentBehavior:addComposite("bar1", Selector, composite1)
	StudentBehavior:addLeaf("mouseX < 0", Leaf, composite2, 0, function() if mouse.Position.x < 0 then return "Success" end return "Failure" end)
	StudentBehavior:addLeaf("mouseY < 0", Leaf, composite2, {}, function() if mouse.Position.y < 0 then return "Success" end return "Failure" end)]]
	--StudentBehavior:addSubTree(moveTowards, composite1)
	--local composite3 = StudentBehavior:addComposite("distToTarget", Sequence, composite1)
		StudentBehavior:addLeaf("distance to target", Leaf, composite1, nil,
			function(vars, student)
				local body = student:get(Body)
				local position = body.Position
				local behavior = student:get(Behavior)
				local targetPosition = behavior.TargetPosition
				--if (targetPosition-position).length > 100 then
					--print(pathfinder:GetPathVector(pathfinder.CurrentGrid, position))--pathfinder.CurrentGrid:coordToIndex(position)))
					--love.graphics.rectangle("fill", body.Position.x, body.Position.y, 100, 100)
					return "Success"
				--end
				--return "Running"
			end)
		--StudentBehavior:addSubTree(moveTowards, composite1)
		--[[StudentBehavior:addLeaf("mouseDown 1 second", Leaf, composite3, {tDown = 0},
		function(vars, student)
			print(student:get(Body))
			vars.tDown = vars.tDown+tick.dt*rateDivisor
			if vars.tDown > 1 then
				return "Success"
			end
			return "Running"
		end)]]
