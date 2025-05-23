--kiObject.lua
--for ki blasts and projectiles.

local gfx = playdate.graphics
local ui = playdate.ui

ActiveKiWaves = {} -- table for updates.

KiObjectRangeTables = {                                         -- There are several defenses against Ki objects. Each has an animation that will begin at 
    
        ["instantTransmission"]=0.50,                                  --various times. For instance, a dodge won't occur until the ki object collides with the defender,
        ["breath"]=0.50,
        ["placeholder"]=0.50,                                                       --but other animations will begin when the ki object is only halfway to the target. This table
        ["badGraze"]=0.90,                                                        --is a matrix of values that tells defenseTransition when to trigger the defense animation. 
        ["medGraze"]=0.85,
        ["lowGraze"]=0.80                                           --any string value indicated here should be given an 'x' value the ki object must be at
                                                                --before the animation will trigger. Otherwise, the animation will trigger once the kiObject
                                                                --reaches the target
                                                                
}

function KiProjectile:new(side, type, name, size, speed, effectTab)
    --type can be underhand, overhand, and fore. 
    local self = gfx.sprite.new()
    setmetatable(self,KiProjectile)
    self.speed = speed or 100 -- default to almost instant.
    self.type = type
    self.name = name
    self.size = size
    self.width = self:getSize()
    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet())
    self:setImage(self.spriteTable[self.tableRef])
    self.dir = self:getDirection()
    self.side = side
    self.effectTab = effectTab
    self.status = "outbound"
    self.x, self.y = side:getPosition()
    self:add()

    local w,h = self:getSize()
    self:setCollideRect(0,0,w,h)
    self.collisionResponseType = gfx.sprite.kCollisionTypeOverlap
    self:setGroups(COLLISION_GROUP.Ki)
    self:setCollidesWithGroups({COLLISION_GROUP.Defender})

    self:moveTo(self.x,self.y)
end

function KiProjectile:getSpriteSheet()
    local spriteTableKi = {}
    if self.size == 16 then
        self.tableRef = kiSprite16Table[self.name]
        return 'assets/images/battleGraphics/ki_16'
    else
        print("KiProjectile size not recognized.")
    end
end

function KiProjectile:draw()
    local img = self:getImage()
    if img then
        img:draw(self.x, self.y)
    end
end

function KiProjectile:getDirection()
    if CurrentPhase == Phase.ATTACK then
        return "right"
    elseif CurrentPhase == Phase.DEFENSE then
        return "left"
    end
end

function KiProjectile:update()

    if self.status == "exploded" then 
        return
    end
    self:checkCollisions(self:getPosition())

    --local dx = (self.dir == "right") and  self.speed or -self.speed
    --local _, _, collisions, count = self:moveWithCollisions(dx, 0)
    --self:moveWithCollisions(dx, 0)

    if self.status == "outbound" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)

        if (self.dir == "right" and self.x > 420) or
           (self.dir == "left"  and self.x < -20) then
            self.status = "transition" 
            self.effectTab.controller:kiTransition(self)
        end
    elseif self.status == "inbound" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
        
        if (self.dir == "right" and self.x >= self.xTrig) or
           (self.dir == "left"  and self.x <= self.xTrig) then
            self.status = "nearTarget"
            self.effectTab.controller:kiStrike(self)
        end
    elseif self.status == "nearTarget" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
            local spriteTable = self:overlappingSprites()
            --printTable(spriteTable)
            print("bitMask")
            for i,v in pairs(spriteTable) do
                if v:getGroupMask() == self:getCollidesWithGroupsMask() then
                    self:explode()
                end
            end        
    elseif self.status == "miss" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
        if (self.dir == "right" and self.x >= 460) or
        (self.dir == "left"  and self.x <= -120) then
            self:remove()
        end
    end
end

function KiProjectile:collidedWith(other)
    print("collided with")
    if other.tag ~= "defender" or self.hitRegistered then 
        return 
    end
    self.hitRegistered = true

    local ctrl = self.effectTab.controller
    local dmg  = ctrl.attSpr.turnOutcome.statHitMiss[1]

    ctrl:onHitConfirmed(dmg)

    -- decide whether the blast physically explodes
    local dodge = ctrl.defSpr.turnOutcome.dodgeType[1]
    if ctrl:getHitOrMissForKi(dodge) then -- boolean for contact causing an explosion
        print("ctrlgetHitOrMiss")
        self:explode()
    else

        self:setCollidesWithGroups{}   -- empty list no further checks
    end
end

function KiProjectile:explode()
    self.x,self.y = self:getPosition()
    self.effectTab.explosion = Explosion:new( 
        self:getExplosionSize(),
        self.x,
        self.y,
        self:getExplosionType()
    )
    self:remove()
end

function KiProjectile:getExplosionSize()
    if self.size == 16 then
        return "small" --stand-in
    end
end

function KiProjectile:getExplosionType()
    return "none"
end

--Ki Wave Type

function KiWave:new(side, type, name, size, speed, effectTab)
    --type can be underhand, overhand, and fore. 
    local self = setmetatable({},KiWave)
    self.speed = speed or 8
    self.type = type
    self.name = name
    self.size = size 
    self.tableRef, self.spritePath = self:getSpriteSheet()
    self.spriteTable = gfx.imagetable.new(self.spritePath)
    self.baseEdgeDistance = 0
    self.segments = {}

    self.beamWidth = self.tableRef.width -- width of beam in pixels
    self.dir = self:getDirection() -- spawn edge to the left or right of the base and travel away
    self.side = side
    self.effectTab = effectTab
    self.xPos,self.yPos = side:getPosition() -- stand in until a position can be determined based on the sprite itself. This will be the "spawn" location.

     -- stand-in until a "hand" location for each sprite can be determined. For now it will simnply be a 50px offset
    if self.dir == "right" then
        self.xPos = self.xPos + 50
    else
        self.xPos = self.xPos - 50
    end

    self.base = KiBase:new(self.tableRef.base,self)
    self.edge = KiEdge:new(self.tableRef.edge,self)
    self.tail = KiTail:new(self.tableRef.tail,self)
    self.segm = KiWaveSeg:new(self.beamWidth,self)
    table.insert(ActiveKiWaves,self)
    print("perhaps draw a rect instead of individual segments for the ki beam?")
    --self:add()
    --self:moveTo(self.xPos,self.yPos)
end

function KiWave:getSpriteSheet()
    local spriteTableKi = {}
    if self.size == 16 then
        return kiSprite16Table[self.name], 'assets/images/battleGraphics/ki_16'
    else
        print("KiProjectile size not recognized.")
    end
end

function KiWave:getDirection()
    if CurrentPhase == Phase.ATTACK then
        return "right"
    elseif CurrentPhase == Phase.DEFENSE then
        return "left"
    end
end

function KiWave:update()
    --[[possible replacement to be employed later for diagonal ki beams.
    local bx, by = self.base:getPosition()
    local ex, ey = self.edge:getPosition()
    local dx = ex - bx
    local dy = ey - by
    local dist = math.sqrt(dx * dx + dy * dy)
    --]]
    local baseLocX, baseLocY = self.base:getPosition()
    local edgeLocX, edgeLocY = self.edge:getPosition()
    if self.dir == "right" then
        self.baseEdgeDistance = edgeLocX - baseLocX
        while self.segments < self.baseEdgeDistance do

        end
    else
        self.baseEdgeDistance = math.abs(edgeLocX - baseLocX)
    end
end


function KiBase:new(image,kiWave) -- spawns at hand level
    local self = gfx.sprite.new()
    setmetatable(self,KiBase)
    self:setImage(kiWave.spriteTable[image])

    self:add()

    self:moveTo(kiWave.xPos, kiWave.yPos)
    print(kiWave.xPos,kiWave.yPos)
    self:setZIndex(1600)

    return self
end

function KiBase:update()

end

function KiEdge:new(image,kiWave) -- spawns next to the base
    local self = gfx.sprite.new()
    setmetatable(self,KiEdge)
    self:setImage(kiWave.spriteTable[image])
    self.status = "outbound"
    self.originOffset = kiWave.size
    self.effectTab = kiWave.effectTa
    self.speed = kiWave.speed
    self.dir = kiWave.dir

    if kiWave.dir == "left" then
        self.originOffset = self.originOffset*-1
    end
    self:moveTo(kiWave.xPos+self.originOffset,kiWave.yPos)

    self:setZIndex(1200)
    self:add()

    local w,h = self:getSize()
    self:setCollideRect(0,0,w,h)
    self.collisionResponseType = gfx.sprite.kCollisionTypeOverlap
    self:setGroups(COLLISION_GROUP.Ki)
    self:setCollidesWithGroups({COLLISION_GROUP.Defender})

    return self
end

function KiEdge:update()

    if self.status == "exploded" then 
        return
    end
    self:checkCollisions(self:getPosition())

    --local dx = (self.dir == "right") and  self.speed or -self.speed
    --local _, _, collisions, count = self:moveWithCollisions(dx, 0)
    --self:moveWithCollisions(dx, 0)

    if self.status == "outbound" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)

        if (self.dir == "right" and self.x > 420) or
           (self.dir == "left"  and self.x < -20) then
            self.status = "transition" 
            self.effectTab.controller:kiTransition(self)
        end
    elseif self.status == "inbound" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
        
        if (self.dir == "right" and self.x >= self.xTrig) or
           (self.dir == "left"  and self.x <= self.xTrig) then
            self.status = "nearTarget"
            self.effectTab.controller:kiStrike(self)
        end
    elseif self.status == "nearTarget" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
            local spriteTable = self:overlappingSprites()
            --printTable(spriteTable)
            print("bitMask")
            for i,v in pairs(spriteTable) do
                if v:getGroupMask() == self:getCollidesWithGroupsMask() then
                    self:explode()
                end
            end        
    elseif self.status == "miss" then
        self:moveBy(self.dir == "right" and self.speed or -self.speed, 0)
        if (self.dir == "right" and self.x >= 460) or
        (self.dir == "left"  and self.x <= -120) then
            self:remove()
        end
    end
end

function KiTail:new(image,kiWave) -- appears at the end of the beam segments, not seen in the initial animation
    local self = gfx.sprite.new()
    setmetatable(self,KiTail)
    self:setImage(kiWave.spriteTable[image])

    return self
end

function KiTail:update()

end

function KiWaveSeg:new(width,xLoc,yLoc,kiWave) -- a series of segments that joins the edge to the base, or tail. 1 added for eachh px the head travels per update
    local self = gfx.sprite.new()
    self:moveTo(xLoc,yLoc)    
    setmetatable(self,KiWaveSeg)
    --self:setImage(kiWave.tableRef[image]) -- commented out for now.will revisit this later

    return self
end

function KiWaveSeg:update()

end

function KiWaveSeg:getSeg()

end