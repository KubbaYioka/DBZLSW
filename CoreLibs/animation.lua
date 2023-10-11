-- Playdate CoreLibs: Animation addons
-- Copyright (C) 2014 Panic, Inc.
import "CoreLibs/object.lua"

playdate.graphics.animation = playdate.graphics.animation or {}

--! **** Animation Loops ****
playdate.graphics.animation.loop = {}

local loopAnimation = playdate.graphics.animation.loop
loopAnimation.__index = loopAnimation


local floor = math.floor

local function updateLoopAnimation(loop, force)

	if loop.paused == true and force ~= true then
		return
	end

	local startTime = loop.t
	local elapsedTime = playdate.getCurrentTimeMilliseconds() - startTime
	local frame = loop.startFrame + floor(elapsedTime / loop._delay) * loop._step

	if loop.loop or frame <= loop.endFrame then
		local startFrame = loop.startFrame
		local numFrames = loop.endFrame + 1 - startFrame
		loop.currentFrame = ((frame-startFrame) % numFrames) + startFrame
	else
		loop.currentFrame = loop.endFrame
		loop.valid = false
	end
end


local nag1 = true
local nag2 = true
local nag3 = true

loopAnimation.__index = function(table, key)

	if key == "frame" then
		updateLoopAnimation(table)
		return table.currentFrame
	
	elseif key == "delay" then
		return table._delay
		
	elseif key == "paused" then
		return table._paused
		
	elseif key == "step" then
		return table._step
	else
		return rawget(loopAnimation, key)
	end
end

loopAnimation.__newindex = function(table, key, value)

	if key == "frame" then
		local newFrame = math.floor(tonumber(value))
		assert(newFrame ~= nil, "playdate.graphics.animation.loop.frame must be a number")
		local newFrame = math.min(table.endFrame, math.max(table.startFrame, newFrame))
		local frameOffset = newFrame - table.startFrame
		table.t = playdate.getCurrentTimeMilliseconds() - (frameOffset * table._delay)
		table.valid = true
		updateLoopAnimation(table, true)
		
	elseif key == "delay" then
		
		local newDelay = tonumber(value)
		assert(newDelay ~= nil, "playdate.graphics.animation.loop.delay must be a number")
		
		local loopTime = table.t
		local currentTime = playdate.getCurrentTimeMilliseconds()
		
		-- calculate the time (.t) the animation needs to be set at to maintain the current frame
		local fractionalFrame = table.startFrame + (((currentTime - loopTime) / table._delay) * table._step)		
		local newLoopTime = currentTime - (((fractionalFrame - table.startFrame) / table._step) * newDelay)
		
		table.t = newLoopTime
		table._delay = newDelay
		
	elseif key == "paused" then

		assert(value == true or value == false, "playdate.graphics.animation.loop.paused can only be set to true or false")

		if value == true and table._paused == false then
			table.pauseTime = playdate.getCurrentTimeMilliseconds()
		elseif value == false and table._paused == true then
			local elapsedPauseTime = table.pauseTime - playdate.getCurrentTimeMilliseconds()
			table.pauseTime = nil
			table.t -= elapsedPauseTime -- offset the original pause time so unpausing carries on at the same frame as when the loop was paused
		end

		table._paused = value
	
	elseif key == "shouldLoop" then

		assert(value == true or value == false, "playdate.graphics.animation.loop.loop can only be set to true or false")

		if table.valid == false and value == true then
			-- restart the loop if necessary
			table.valid = true
			table.t = playdate.getCurrentTimeMilliseconds()
		end
		
		if value == false then
			-- adjust the start time of the loop so that it's what it would have been if the loop started at the beginning of this cycle
			local currentTime = playdate.getCurrentTimeMilliseconds()
			local oneLoopDuration = table._delay * (table.endFrame - table.startFrame + 1)
			table.t += (floor((currentTime - table.t) / oneLoopDuration) * oneLoopDuration)			
		end
		
		table.loop = value
		
	elseif key == "step" then
		assert(value ~= nil and value > 0, "playdate.graphics.animation.loop.step must be a positive integer")
		local newStep = math.floor(tonumber(value))
		table._step = newStep

	else
		rawset(table, key, value)
	end
end


function loopAnimation.new(delay, imageTable, shouldLoop)

	assert(delay~=loopAnimation, 'Please use playdate.graphics.animation.loop.new() instead of playdate.graphics.animation.loop:new()')

	local o = {}

	o._delay = delay or 100
	o.startFrame = 1
	o.currentFrame = 1
	o.endFrame = 1
	o._step = 1
	o.loop = shouldLoop ~= false
	o._paused = false
	o.valid = true
	o.t = playdate.getCurrentTimeMilliseconds()

	if imageTable ~= nil then
		o.imageTable = imageTable
		o.endFrame = #imageTable
	else
		imageTable = nil
	end

	setmetatable(o, loopAnimation)
	return o
end


function loopAnimation:setImageTable(it)
	self.imageTable = it
	if it ~= nil then
		self.endFrame = #it
	end
end


function loopAnimation:isValid()
	return self.valid
end


function loopAnimation:image()
	if self.imageTable ~= nil then
		return self.imageTable[self.frame]
	end
	return nil
end


function loopAnimation:draw(x, y, flipped)
	local img = self:image()
	if img ~= nil then
		img:draw(x, y, flipped)
		return true
	end
	return false
end


--! **** Blinkers ****
playdate.graphics.animation.blinker = {}

local blinker = playdate.graphics.animation.blinker

blinker.__index = function(table, key)

	if key == "default" then
		return table._default
	else
		return rawget(blinker, key)
	end
end

blinker.__newindex = function(table, key, value)
	
	if key == "default" then
		assert(value ~= nil and type(value) == "boolean", "playdate.graphics.animation.blinker.default must be a boolean")
		table._default = value
		
		if table.running == false then
			table.on = table._default
		end
	else
		rawset(table, key, value)
	end
end

blinker.allBlinkers = {}
blinker.needsRemoval = false



local function setBlinkerDefaults(b, o, ...)
	
	local onDuration, offDuration, loop, cycles, default
	
	if (type(o) == "table") then
		onDuration = o.onDuration
		offDuration = o.offDuration
		loop = o.loop
		cycles = o.cycles
		default = o.default
	else
		onDuration = o
		offDuration, loop, cycles, default = select(1, ...)
	end
	
	b.cycles = (cycles or b.cycles) or 6
	b.onDuration = (onDuration or b.onDuration) or 200
	b.offDuration = (offDuration or b.offDuration) or 200
	
	if loop ~= nil then b.loop = loop end
	if b.loop == nil then b.loop = false end
	
	if default ~= nil then b._default = default end
	if b._default == nil then b._default = true end
	
end

-- accepts a table with defaults for keys: cycles, onDuration, offDuration, default, loop
-- or those values as optional keys: blinker.new([onDuration, [offDuration, [loop, [cycles, [default]]]]])

function blinker.new(o, ...)
  assert(o~=blinker, 'Please use blinker.new() instead of blinker:new()')

  local b = {}
  setmetatable(b, blinker)
  setBlinkerDefaults(b, o, ...)
  b.t = 0
  b.counter = 0
  b.running = false
  b.valid = true
  b.on = b._default
  table.insert(blinker.allBlinkers, b)
  return b
end

local function removeInvalidBlinkers()
  -- find blinkers to remove

  for l = #blinker.allBlinkers, 1, -1 do

    local blinkerToCheck = blinker.allBlinkers[l]

    if not blinkerToCheck.valid then
      table.remove(blinker.allBlinkers, l)
    end

  end

  blinker.needsRemoval = false

end

function blinker:updateAll()
  for i=1, #blinker.allBlinkers do
    blinker.allBlinkers[i]:update()
	end

  if blinker.needsRemoval then removeInvalidBlinkers() end
end

function blinker:update()

  if not self.running then return end
  local elapsedTime = playdate.getCurrentTimeMilliseconds()

  if elapsedTime - self.t >= self.onDuration and self.counter > 0 and self.on then

    self.t = elapsedTime
    self.on = not self.on
    self.counter = self.counter - 1

  elseif elapsedTime - self.t >= self.offDuration and self.counter > 0 and not self.on then
    self.t = elapsedTime
    self.on = not self.on
    self.counter = self.counter - 1

  elseif self.counter == 0 then
    self.on = self._default
    self.t = 0
    self.running = false

    if self.loop then self:start() end

  end

end

function blinker:startLoop()
  self:start(nil, nil, true)
end

-- same arguments as .new()
function blinker:start(o, ...)
	
  setBlinkerDefaults(self, o, ...)
	
  self.counter = self.cycles
  self.t = playdate.getCurrentTimeMilliseconds()
  self.running = true
  self.on = self.default
end

function blinker:stop()
  self.counter = 0
  self.on = self._default
  self.running = false
end

function blinker.stopAll()
  for i=1, #blinker.allBlinkers do
    blinker.allBlinkers[i]:stop()
	end

end

function blinker:remove()
  self.valid = false
  blinker.needsRemoval = true
end
