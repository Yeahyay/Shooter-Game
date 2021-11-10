local cute = require("cute")
local shapes = require("src.shapes")

notion("Can compare numbers, strings, etc", function ()
  check(1).is(1)
  check("hello").is("hello")
end)

notion("Can compare tables", function ()
  check({1,2,3}).shallowMatches({1,2,3})
  check({one="two", three="four"}).shallowMatches({one="two", three="four"})
end)

notion("Can check things that draw", function ()
  minion("rectangleMinion", love.graphics, 'rectangle')
  minion("setColorMinion", love.graphics, 'setColor')

  shapes.tiles(love.graphics)

  check(report("rectangleMinion").calls).is(1938)
  check(report("setColorMinion").calls).is(1938)
  check(report("rectangleMinion").args[1][1]).is('fill')
end)

notion("Minions get reset after each call", function ()
  minion("setColorMinion", love.graphics, "setColor")
  minion("circleMinion", love.graphics, "circle")

  shapes.circle(100)

  check(report("setColorMinion").calls).is(1)
  check(report("circleMinion").args[1]).shallowMatches({"line", 400, 300, 0, 100})
end)

notion("Can overwrite return values", function ()
  minion("width", love.graphics, "getWidth").nobbleReturnValue(12345)

  local foo = love.graphics.getWidth()

  check(foo).is(12345)
end)

notion("Return values are reset", function ()
  local bar = love.graphics.getWidth()

  check(bar).is(800)
end)
