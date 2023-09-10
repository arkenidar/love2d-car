
local drawable
local points = {}

function love.load()
  love.window.setTitle( ' "arcade-car" in Love2D' )
  drawable = love.graphics.newImage("car.png")

  math.randomseed(os.time())
  local points_count = 100
  while points_count > 0 do
    table.insert(points, {math.random(-100,400), math.random(-100,400)} )
    points_count = points_count - 1
  end
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

local camera_x, camera_y = 100, 100

-- input: mouse, touch also
function love.mousemoved( x, y, dx, dy )
  -- mouse drag to change speeds
  if love.mouse.isDown(1) then
  camera_x = camera_x + dx/2
  camera_y = camera_y + dy/2
  end
end

function love.draw()

  love.graphics.push()
  love.graphics.translate(camera_x,camera_y)

  love.graphics.setColor(0,1,0)
  for _,point in ipairs(points) do
    love.graphics.rectangle("fill", point[1], point[2], 10,10)
  end

  love.graphics.setColor(1,1,1)
  love.graphics.draw( drawable, x, y, rotation, 1, 1, 50, 53)

  love.graphics.pop()

  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", 10, 10, 250,50)

  love.graphics.setColor(0,0,1)
  love.graphics.print("use arrows-keys on keyboard", 15, 15)
  love.graphics.print("use click+drag for camera position", 15, 30)
end
