local Suit = require('lib.suit')

local config = {
  pixel_size = 4
}

local colors = {}

-- shows the fire
local grid = {}

-- where 1 is the minimum and 36 is the maximum
local max_fire_intensity = 36
local min_fire_intensity = 1

-- the current being used
local fire_intensity = max_fire_intensity

local function assign_min_max_fire_intensity(intensity)
	if intensity > max_fire_intensity then intensity = max_fire_intensity end
  if intensity < min_fire_intensity then intensity = min_fire_intensity end

	return intensity
end

local function set_new_intensity(is_increase)
	for i=1, config.row_size do
		local current_fire_intensity = grid[i]

		if current_fire_intensity >= min_fire_intensity then
			local decay = math.floor(math.random(0,1) * 5)

			local new_intensity = 0

			if is_increase then new_intensity = current_fire_intensity + decay
			else new_intensity = current_fire_intensity - decay end

			new_intensity = assign_min_max_fire_intensity(new_intensity)

			grid[i] = new_intensity
		end
	end
end

function love.keypressed(key)
	local is_increase = false

  if key == 'escape' then love.event.push('quit') end

  if key == 'up' or key == 'w' then
    fire_intensity = fire_intensity + 1
		is_increase = true
  end

  if key == 'down' or key == 's' then
    fire_intensity = fire_intensity - 1
		is_increase = false
  end

	set_new_intensity(is_increase)
end

function love.load()
  local w, h = love.window.getMode()

  config.row_size = math.floor(w/config.pixel_size)
  config.column_size = math.floor(h/config.pixel_size)
  config.grid_size = (config.row_size * config.column_size)

  -- for colors, I'll use the image colors.png in this folder.
  colors.img = love.graphics.newImage('colors.png')

  -- the image has 36 colors and the image is 899 width,
  -- so dividing, it will be ~ 24w each color
  for i=1, 36 do
    -- quad == fraction of an image
    colors[i] = love.graphics.newQuad(
      (((i-1) * 24) + i),
      0,
      config.pixel_size,config.pixel_size,
      colors.img:getDimensions()
    )
  end

  for i=1, config.grid_size do
    grid[i] = max_fire_intensity
  end
end

local function set_min_fire_intensity()
	for i = 1, config.grid_size do
		grid[i] = min_fire_intensity
	end
end

local function set_max_fire_intensity()
	for i = 1, config.grid_size do
		grid[i] = max_fire_intensity
	end
end

-- we need something to slow down the fire
local timer = 0

function love.update(dt)
  timer = timer + dt

  if timer >= 0.05 then
    for i in ipairs(grid) do
      if i <= config.row_size then
        i = i + config.row_size
      end

      local decay = math.random(0,1)

      local force = grid[i - config.row_size] - decay

      if force < 1 then force = 1 end
      if force > 36 then force = 36 end

      grid[i - decay] = force
    end

    timer = 0
  end

	local min_fire_button = Suit.Button('Min Fire Intensity', 5, 10, 150, 50)

	if min_fire_button.hit then
		set_min_fire_intensity()
	end

	local max_fire_button = Suit.Button('Max Fire Intensity', 170, 10, 150, 50)

	if max_fire_button.hit then
		set_max_fire_intensity()
	end
end

function love.draw()
  for i,force in ipairs(grid) do
    i = #grid - i

    local x = (i % config.row_size) * config.pixel_size
    local y = math.floor((i - 1) / config.row_size) * config.pixel_size

    love.graphics.draw(colors.img, colors[force], x,y)
  end

	Suit.draw()
end
