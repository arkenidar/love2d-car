if arg[#arg] == "-debug" then require("mobdebug").start() end

-- global objects
local movable = {}
local points = {}

-- load: prepare, one time setup
function love.load()
  love.window.setTitle( ' "arcade-car" in Love2D' )

  movable.drawable_data = love.image.newImageData("car.png")
  movable.drawable = love.graphics.newImage(movable.drawable_data)

  math.randomseed(os.time())
  for _=1,100 do
    table.insert(points, {math.random(-100,400), math.random(-100,400)} )
  end
end

-- keys
local keys_down = {}
function love.keypressed( key ) keys_down[key]=true end
function love.keyreleased( key ) keys_down[key]=false end

-- roto-translation transformation
local transform = { x = 150, y = 150, rotation = math.pi/2 }

-- update every frame before drawing it
function love.update(dt)
  local rotation_increment = dt*math.pi/2

  -- rotate direction clock-wise
  if keys_down["right"] then
    transform.rotation = transform.rotation + rotation_increment
  end

  -- rotate direction counter-clock-wise
  if keys_down["left"] then
    transform.rotation = transform.rotation - rotation_increment
  end

  -- move forward in the current direction
  if keys_down["up"] then
    transform.x = transform.x - math.sin(-transform.rotation)*200*dt
    transform.y = transform.y - math.cos(-transform.rotation)*200*dt
  end

  -- quit with key
  if keys_down["escape"] then love.event.quit() end

end

local camera = {x=100, y=100}

-- input: mouse, touch also
function love.mousemoved( x, y, dx, dy )
  -- mouse drag to change camera position (x & y)
  if love.mouse.isDown(1) then
    camera.x = camera.x + dx
    camera.y = camera.y + dy
  end
end

local function draw_debug_gizmos()

  -- draw debug support gizmo
  love.graphics.setColor(1,0,0)
  local square_size = 20

  local function draw_gizmo(x,y)
    love.graphics.rectangle("line", x-square_size/2, y-square_size/2, square_size,square_size)
  end
  draw_gizmo(transform.x,transform.y)

  local angle = math.atan(transform.h/transform.w)/2

  local function draw_gizmo_corner(angle1, angle2)
    draw_gizmo(transform.x-math.sin(-transform.rotation+angle1)*transform.w, transform.y-math.cos(-transform.rotation+angle2)*transform.h)
  end

  ---[[
  draw_gizmo_corner(-angle, -angle) -- front right
  draw_gizmo_corner(angle, angle)   -- front left
  angle = angle + math.pi
  draw_gizmo_corner(-angle, -angle) -- back left
  draw_gizmo_corner(angle, angle)   -- back right
  --]]

end

-- render every frame here
function love.draw()

  -- begin camera
  love.graphics.push()
  love.graphics.translate(camera.x,camera.y)

  -- draw points
  love.graphics.setColor(0,1,0)
  for _,point in ipairs(points) do
    love.graphics.rectangle("fill", point[1], point[2], 10,10)
  end

  -- draw movable
  love.graphics.setColor(1,1,1)
  transform.w=movable.drawable:getWidth()/2
  transform.h=movable.drawable:getHeight()/2
  love.graphics.draw( movable.drawable, transform.x, transform.y, transform.rotation, 1, 1,
    transform.w, transform.h )

  draw_debug_gizmos()

  -- end camera
  love.graphics.pop()

  -- camera ended

  -- draw back-ground for texts
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", 10, 10, 250,50)

  -- draw texts
  love.graphics.setColor(0,0,1)
  love.graphics.print("use arrows-keys on keyboard", 15, 15)
  love.graphics.print("use click+drag for camera position", 15, 30)
end
