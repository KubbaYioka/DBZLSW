
import "CoreLibs/easing.lua"

local geo <const> = playdate.geometry
local max <const> = math.max
local min <const> = math.min

playdate.graphics.animator = {}
playdate.graphics.animator.__index = playdate.graphics.animator

local function newNumberOrPointAnimation(duration, startValue, endValue, easingFunction, startTimeOffset)
	
	local startTimeOffset = startTimeOffset or 0
	local easingFunction = easingFunction or playdate.easingFunctions.linear

	local st = playdate.getCurrentTimeMilliseconds()

	local a = {
		startTime = st,
		startTimeOffset = startTimeOffset,
		duration = duration,
		endTime = st + duration,
		startValue = startValue,
		endValue = endValue,
		change = endValue - startValue,
		easingFunction = easingFunction or playdate.easingFunctions.linear,
		s = nil,
		easingAmplitude = nil,
		easingPeriod = nil,
		lastTime = playdate.getCurrentTimeMilliseconds(),
		repeatCount = 0
	}

	setmetatable(a, playdate.graphics.animator)
	return a
end


local function verifyParts(parts)
	local count = #parts
	for i = 1, count do
		local part = parts[i]
		assert(getmetatable(part) == geo.lineSegment or getmetatable(part) == geo.arc or getmetatable(part) == geo.polygon, "All elements in the parts array must be one of either playdate.geometry.lineSegment, playdate.geometry.arc, or playdate.geometry.polygon")
	end	
end


local function newPartsAnimationWithDurations(durations, parts, easingFunctions, startTimeOffset)
	
	verifyParts(parts)
	assert(#durations == #parts, "Number of elements in `durations` must equal number of elements in `parts`")
	assert(#easingFunctions == #parts, "Number of elements in `easingFunctions` must equal number of elements in `parts`")
	
	local startTimeOffset = startTimeOffset or 0
	local easingFunction = easingFunction or playdate.easingFunctions.linear
	
	local st = playdate.getCurrentTimeMilliseconds()
	
	local a = {
		startTime = st,
		startTimeOffset = startTimeOffset,
		duration = duration,
		-- endTime = st + duration,
		
		animationParts = parts,
		durations = durations,
		easingFunctions = easingFunctions,
		
		s = nil,
		easingAmplitude = nil,
		easingPeriod = nil,
		lastTime = playdate.getCurrentTimeMilliseconds(),
		
		repeatCount = 0
	}
	
	local count = #a.animationParts
	
	if count > 0 then
		
		a.totalDuration = 0
		a.durationTotals = {}

		for i = 1, count do
			
			local part = a.animationParts[i]
			
			if getmetatable(part) == geo.lineSegment or getmetatable(part) == geo.arc or getmetatable(part) == geo.polygon then
				a.totalDuration += a.durations[i]
				a.durationTotals[i] = a.totalDuration
			end
		end
		
		a.endTime = st + a.totalDuration
		a.duration = a.totalDuration
		
	end
	
	setmetatable(a, playdate.graphics.animator)
	return a
end


local function newPartsAnimation(duration, parts, easingFunction, startTimeOffset)
	
	verifyParts(parts)
	
	local startTimeOffset = startTimeOffset or 0
	local easingFunction = easingFunction or playdate.easingFunctions.linear
	
	local st = playdate.getCurrentTimeMilliseconds()
	
	local a = {
		startTime = st,
		startTimeOffset = startTimeOffset,
		duration = duration,
		endTime = st + duration,
		
		animationParts = parts,
		
		easingFunction = easingFunction or playdate.easingFunctions.linear,
		s = nil,
		easingAmplitude = nil,
		easingPeriod = nil,
		lastTime = playdate.getCurrentTimeMilliseconds(),
		
		lengths = {},
		
		repeatCount = 0
	}
		
	local count = #a.animationParts
	
	if count > 0 then
		
		a.totalLength = 0

		for i = 1, count do
			
			local part = a.animationParts[i]
			
			if getmetatable(part) == geo.lineSegment or getmetatable(part) == geo.arc or getmetatable(part) == geo.polygon then
				a.totalLength += part:length()
				a.lengths[i] = a.totalLength
			end
		end
		
	end
	
	setmetatable(a, playdate.graphics.animator)
	return a
end


local function newLineSegmentAnimation(duration, lineSegment, easingFunction, startTimeOffset)
	assert(getmetatable(lineSegment) == geo.lineSegment, "Error: lineSegment argument must be a playdate.geometry.lineSegment")
	return newPartsAnimation(duration, {lineSegment}, easingFunction, startTimeOffset)
end


local function newArcAnimation(duration, arc, easingFunction, startTimeOffset)
	assert(getmetatable(arc) == geo.arc, "Error: arc argument must be a playdate.geometry.arc")
	return newPartsAnimation(duration, {arc}, easingFunction, startTimeOffset)
end


local function newPolygonAnimation(duration, poly, easingFunction, startTimeOffset)
	assert(getmetatable(poly) == geo.polygon, "Error: polygon argument must be a playdate.geometry.polygon")
	return newPartsAnimation(duration, {poly}, easingFunction, startTimeOffset)
end


function playdate.graphics.animator.new(a, b, c, d, e)
	
	-- playdate.graphics.animator.newNumberOrPointAnimation(duration, startValue, endValue, [easingFunction, [startTimeOffset]])
	-- playdate.graphics.animator.newLineSegmentAnimation(duration, lineSegment, [easingFunction, [startTimeOffset]])
	-- playdate.graphics.animator.newPolygonAnimation(duration, poly, [easingFunction, [startTimeOffset]])
	-- playdate.graphics.animator.newPartsAnimation(duration, parts, [easingFunction, [startTimeOffset]])
	-- playdate.graphics.animator.newPartsAnimationWithDurations(durations, parts, easingFunctions, [startTimeOffset])
	
	if type(b) == "number" or getmetatable(b) == geo.point then
		return newNumberOrPointAnimation(a, b, c, d, e)
	elseif getmetatable(b) == geo.lineSegment then
		return newLineSegmentAnimation(a, b, c, d)
	elseif getmetatable(b) == geo.arc then
		return newArcAnimation(a, b, c, d)
	elseif getmetatable(b) == geo.polygon then
		return newPolygonAnimation(a, b, c, d)
	elseif type(b) == "table" then
		if type(a) == "number" then
			return newPartsAnimation(a, b, c, d)
		else
			return newPartsAnimationWithDurations(a, b, c, d)
		end
	end
end

function playdate.graphics.animator:reset(duration)
	if duration ~= nil then self.duration = duration end
	self.startTime = playdate.getCurrentTimeMilliseconds()
	self.didend = false
	self.lastTime = self.startTime
	self.endTime = self.startTime + self.duration
end

local function checkTime(self, t)
	t -= self.startTimeOffset
	
	if t < 0 then return 0 end

	local len = self.reverses and 2 * self.duration or self.duration
	
	if len <= 0 then
		self.didend = true
		return 1
	end
	
	local reps = t // len
	t %= len

	-- for numbers and points the start and end values are not nil, but they are for the others (because the start value is implied by the geometry)
	
	if not self.repeats and self.repeatCount >= 0 and reps > self.repeatCount then
		self.didend = true
		return (self.reverses and self.repeatCount % 2 == 1) and 0 or self.duration
	end

	return t
end

function playdate.graphics.animator:valueAtTime(intime)
	
	time = checkTime(self, intime)
	
	if time > self.duration then -- reverse
		time = 2 * self.duration - time
	end

	if self.startValue ~= nil then
		
		if self.didend then
			return self.reverses and self.startValue or self.endValue
		elseif time < 0 then
			return self.startValue
		end

		if type(self.startValue) == "number" then
			return self.easingFunction(time, self.startValue, self.change, self.duration, self.s or self.easingAmplitude, self.easingPeriod)
		else
			local x <const> = self.easingFunction(time, self.startValue.x, self.change.x, self.duration, self.s or self.easingAmplitude, self.easingPeriod)
			local y <const> = self.easingFunction(time, self.startValue.y, self.change.y, self.duration, self.s or self.easingAmplitude, self.easingPeriod)
			return geo.point.new(x, y)
		end
		
	elseif self.animationParts ~= nil then
		if self.durations == nil then
		
			-- just one duration for this animation
		
			if #self.animationParts > 0 then
			
				local part, dist
				
				if self.totalLength > 0 and not self.didend then
					-- figure out which part we're currently on
					local d = self.easingFunction(time, 0, self.totalLength, self.duration, self.s or self.easingAmplitude, self.easingPeriod)
					
					local i = 1
					while self.lengths[i] ~= nil and d > self.lengths[i] and #self.lengths >= i and i < #self.animationParts do				
						i += 1
					end

					part = self.animationParts[i]
					dist = d - (self.lengths[i-1] or 0)
				
				elseif self.reverses then
					part = self.animationParts[1]
					dist = 0
				else
					part = self.animationParts[#self.animationParts]
					dist = self.lengths[#self.lengths] - (self.lengths[#self.lengths-1] or 0)
				end

				if getmetatable(part) == geo.lineSegment then
					return part:pointOnLine(dist, true)
				
				elseif getmetatable(part) == geo.arc then
					return part:pointOnArc(dist, true)
					
				elseif getmetatable(part) == geo.polygon then
					return part:pointOnPolygon(dist, true)
				end
				
			end
		else
			local i = 1

			if self.didend then
				i = self.reverses and 1 or #self.animationParts
				time = self.reverses and 0 or self.durations[i]
			else
				-- figure out which part we're on
				while time > self.durations[i] do
					time -= self.durations[i]
					i += 1
				end
			end
			
			local part = self.animationParts[i]
			local easingFunction = self.easingFunctions[i]
			
			local dist = easingFunction(time, 0, part:length(), self.durations[i], self.s or self.easingAmplitude, self.easingPeriod)
			
			if getmetatable(part) == geo.lineSegment then
				return part:pointOnLine(dist, true)
			
			elseif getmetatable(part) == geo.arc then
				return part:pointOnArc(dist, true)
				
			elseif getmetatable(part) == geo.polygon then
				return part:pointOnPolygon(dist, true)				
			end
			
		end
	end
end

function playdate.graphics.animator:currentValue()
	return self:valueAtTime(playdate.getCurrentTimeMilliseconds() - self.startTime)
end

function playdate.graphics.animator:progress()
	if self.repeats or self.repeatCount < 0 then return nil end

	local len = self.reverses and 2 * self.duration or self.duration
	len *= 1 + self.repeatCount
	
	if len <= 0 then return 1 end
	
	local p = (playdate.getCurrentTimeMilliseconds() - self.startTime) / len
	return p < 0 and 0 or p > 1 and 1 or p
end

function playdate.graphics.animator:ended()

	if self.didend then return true end
	
	-- only returns true if either this function or currentValue() has been called since the animation ended
	-- this is to allow animations to fully finish before true is returned, which often triggers cleanup code
	checkTime(self, playdate.getCurrentTimeMilliseconds() - self.startTime)
	return false
	
end
