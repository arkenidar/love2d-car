--- debuggers

-- https://github.com/pkulchenko/MobDebug in e.g. ZeroBrane Studio IDE
if arg[#arg] == "-debug" then require("mobdebug").start() end -- see docs

-- tomblind.local-lua-debugger-vscode in Microsoft VisualStudio Code: see also ".vscode/launch.json"
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then require("lldebugger").start() end -- see docs

-- global objects:

-- user moves this
local movable = {}

-- roto-translation transformation
local transform = { x = 150, y = 150, rotation = math.pi/2 }

local floor = {}

-- randomly-generated
local points = { square_size=10 }

-- load: prepare, one time setup
function love.load()
  love.window.setTitle( ' "arcade-car" in Love2D' )

  floor.drawable_data = love.image.newImageData("floor.png")
  floor.drawable = love.graphics.newImage(floor.drawable_data)

  movable.drawable_data = love.image.newImageData("car.png")
  movable.drawable = love.graphics.newImage(movable.drawable_data)

  transform.w=movable.drawable:getWidth()/2
  transform.h=movable.drawable:getHeight()/2
  transform.angle = math.atan(transform.w/transform.h)
  transform.distance = math.sqrt(transform.w^2 + transform.h^2)

  math.randomseed(os.time())
  for _=1,100 do
    local position = {math.random( 0,600-1 ), math.random( 0,400-1 )}
    local function valid_point(point_position)
      local drawable_data = floor.drawable_data
      local function position_check(position_to_check)
        local w = drawable_data:getWidth()
        local h = drawable_data:getHeight()
        local x, y = position_to_check[1], position_to_check[2]
        local inside_rectangle = x>=0 and y>=0 and x<w and y<h
        if not inside_rectangle then
          return true -- case: out-side
        end
        local r,g,b,a = drawable_data:getPixel(x, y)
        return a==0 -- case: transparent
      end
      local x, y = point_position[1], point_position[2] -- square center
      local square_size = points.square_size
      if
       position_check( {x-square_size/2, y-square_size/2} ) and
       position_check( {x-square_size/2, y+square_size/2} ) and
       position_check( {x+square_size/2, y-square_size/2} ) and
       position_check( {x+square_size/2, y+square_size/2} ) then
         return true
      end

      return false
    end

    if valid_point(position) then table.insert(points, position ) end
  end

  local emoji_font = love.graphics.newFont("Symbola.ttf", 25)
  love.graphics.setFont(emoji_font)
end

-- keys
local keys_down = {}
function love.keypressed( key ) keys_down[key]=true end
function love.keyreleased( key ) keys_down[key]=false end

local function inside_polygon(polygon, point)
  local last = polygon[#polygon]
  for i = 1, #polygon do
    local current = polygon[i]

    local function halfplane(px, p1, p2)
      return ( (p2[1] - p1[1]) * (px[2] - p1[2]) - (p2[2] - p1[2]) * (px[1] - p1[1]) ) >= 0
    end

    if halfplane(point, last, current) then
      return false
    end

    last = current
  end
  return true
end

local function bounding_box_corner(angle_xy)
  local x = transform.x-math.sin(-transform.rotation+angle_xy)*transform.distance
  local y = transform.y-math.cos(-transform.rotation+angle_xy)*transform.distance
  return {x,y}
end

-- update every frame before drawing it
function love.update(dt)

  -- quit with key
  if keys_down["escape"] then love.event.quit() end

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

  local quad = {}
  local angle = transform.angle
  quad[1] = bounding_box_corner(-angle) -- front right
  quad[2] = bounding_box_corner(angle)  -- front left
  angle = angle + math.pi
  quad[3] = bounding_box_corner(-angle) -- back left
  quad[4] = bounding_box_corner(angle)  -- back right

  local points_after = { square_size = points.square_size }
  for _,point in ipairs(points) do
    if not inside_polygon(quad, point) then
      table.insert(points_after, point)
    end
  end
  points = points_after

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
  local square_size = 5

  local function draw_gizmo(x,y)
    love.graphics.rectangle("line", x-square_size/2, y-square_size/2, square_size,square_size)
  end
  draw_gizmo(transform.x,transform.y)

  local function draw_gizmo_corner(angle_xy)
    local point = bounding_box_corner(angle_xy)
    draw_gizmo( point[1], point[2])
  end

  ---[[
  local angle = transform.angle
  draw_gizmo_corner(-angle) -- front right
  draw_gizmo_corner(angle)  -- front left
  angle = angle + math.pi
  draw_gizmo_corner(-angle) -- back left
  draw_gizmo_corner(angle)  -- back right
  --]]

end

-- render every frame here
function love.draw()

  -- begin camera
  love.graphics.push()
  love.graphics.translate(camera.x,camera.y)

  -- floor
  love.graphics.draw(floor.drawable)

  -- draw points
  love.graphics.setColor(0,1,0)
  local square_size = points.square_size
  for _,point in ipairs(points) do
    love.graphics.rectangle("fill", point[1]-square_size/2, point[2]-square_size/2, square_size,square_size )
  end

  -- draw movable
  love.graphics.setColor(1,1,1)
  love.graphics.draw( movable.drawable, transform.x, transform.y, transform.rotation, 1, 1,
    transform.w, transform.h )

  draw_debug_gizmos()

  -- end camera
  love.graphics.pop()

  -- camera ended

  -- draw back-ground for texts (with transparence)
  love.graphics.setColor(1,1,1,0.7)
  love.graphics.rectangle("fill", 10, 10, 450,50)

  -- draw texts
  love.graphics.setColor(0,0,1)
  love.graphics.print("😀 use arrows-keys on keyboard", 15, 15)
  love.graphics.print("use click+drag for camera position", 15, 35)
end
