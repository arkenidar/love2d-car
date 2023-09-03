
local drawable

function love.load()
  love.window.setTitle( ' "arcade-car" in Love2D' )
  drawable = love.graphics.newImage("car.png")
end

local keys_down = {}

function love.keypressed( key )
  keys_down[key]=true
  if key=="left" then keys_down["right"]=false end
  if key=="right" then keys_down["left"]=false end
end

function love.keyreleased( key )
  keys_down[key]=false
end

local x = 150
local y = 150
local rotation = math.pi/2

function love.update(dt)
  local rotation_increment = dt*math.pi/2

  if keys_down["right"] then
    rotation = rotation + rotation_increment
  end

  if keys_down["left"] then
    rotation = rotation - rotation_increment
  end

  if keys_down["up"] then
    x = x - math.sin(-rotation)*200*dt
    y = y - math.cos(-rotation)*200*dt
  end

  if keys_down["escape"] then
    love.event.quit()
  end

end

function love.draw()
  love.graphics.print("use arrows-keys on keyboard", 8, 6)

  love.graphics.draw( drawable, x, y, rotation, 1, 1, 50, 53)
end
