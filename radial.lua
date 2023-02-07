-- radial.
-- @eigen
--
--


-- ------------------------------------------------------------------------
-- conf

local fps = 15

local NB_SAMPLES = 1000
-- local NB_SAMPLES = 100

local ZOOM_FACTOR = 25

local SCREEN_H = 64
local SCREEN_W = 128

local MIN_ORDER = 3
local MAX_ORDER = 100
-- local MAX_ORDER = 15


-- ------------------------------------------------------------------------
-- state

local polygon_order = 5
offset = 0


-- ------------------------------------------------------------------------
-- script lifecycle

local redraw_clock

function init()
  -- screen.aa(1)
  screen.aa(0)
  screen.line_width(1)

  redraw_clock = clock.run(
    function()
      local step_s = 1 / fps
      while true do
        clock.sleep(step_s)
        redraw()
      end
  end)
end

function cleanup()
  clock.cancel(redraw_clock)
end


-- ------------------------------------------------------------------------
-- user input

function enc(n, v)
  local sign = 1
  if v < 0 then
    sign = -1
  end

  if n == 2 then
    -- polygon_order = util.clamp(polygon_order + (v/10), MIN_ORDER, MAX_ORDER)
    polygon_order = util.clamp(polygon_order + sign, MIN_ORDER, MAX_ORDER)
  elseif n == 3 then
    offset = util.clamp(math.floor(offset + v), 0, 99)
  end
end


-- ------------------------------------------------------------------------
-- screen

--- Cos of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- @param x value
local function cos1(x)
  return math.cos(math.rad(x * 360))
end

--- Sin of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- Result is sign-inverted, like in PICO-8
-- @param x value
local function sin1(x)
  return math.sin(math.rad(x * 360))
end


local function polygonV(angle, n, teeth)
  -- looks correct but amplitude fluctuates, missing normalization
  local r = cos1(math.pi/n) / cos1((2*math.pi * (n * angle ) % 1 / n) - (math.pi/n) + teeth)

  -- incorrect but pwetty
  -- local r = cos1(math.pi/n) / cos1(((2*math.pi/n) * ((n*angle/(2*math.pi)) % 1)) - (math.pi/n) + teeth)
  -- local r = cos1(math.pi/n) / cos1((2*math.pi * (n * angle / (2 * math.pi)  ) % 1 / n) - (math.pi/n) + teeth)

  return r
end


function redraw()
  screen.clear()

  for sample=0,(NB_SAMPLES-1) do
    local angle = sample/NB_SAMPLES
    local r = polygonV(angle, polygon_order, offset/100)
    -- local x = r * cos1(2*math.pi * angle) * ZOOM_FACTOR / polygon_order + (SCREEN_W/2)
    -- local y = r * sin1(2*math.pi * angle) * ZOOM_FACTOR / polygon_order + (SCREEN_H/2)
    local x = r * cos1(2*math.pi * angle) * ZOOM_FACTOR + (SCREEN_W/2)
    local y = r * sin1(2*math.pi * angle) * ZOOM_FACTOR + (SCREEN_H/2)
    screen.pixel(x, y)
    screen.fill()
  end

  screen.update()
end
