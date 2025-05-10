--kiObject.lua
--for ki blasts and projectiles.

local gfx = playdate.graphics
local ui = playdate.ui

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
    local self = gfx.sprite.new()
    setmetatable(self,KiWave)
    self.speed = speed or 8
    self.type = type
    self.name = name
    self.size = size 
    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet())

    self.base = KiBase:new(self.tableRef.base,self)
    self.edge = KiEdge:new(self.tableRef.edge,self)
    self.tail = KiTail:new(self.tableRef.tail,self) -- end of the beam. may or may not use
    self.beamWidth = self.tableRef.width -- width of beam in pixels
    self.dir = self:getDirection() -- spawn edge to the left or right of the base and travel away
    self.side = side
    self.effectTab = effectTab
    self.xPos,self.yPos = side:getPosition()
    self:add()
    self:moveTo(self.xPos,self.yPos)
end

function KiWave:getSpriteSheet()
    local spriteTableKi = {}
    if self.size == 16 then
        self.tableRef = kiSprite16Table[self.name]
        return 'assets/images/battleGraphics/ki_16'
    else
        print("KiProjectile size not recognized.")
    end
end

function KiWave:update()
    
end

function KiBase:new(image,kiWave)
    local self = gfx.sprite.new()
    setmetatable(self,KiWave)
end

function KiEdge:new(image,kiWave)
    local self = gfx.sprite.new()
    setmetatable(self,KiWave)
end

function KiTail:new(image,kiWave)
    local self = gfx.sprite.new()
    setmetatable(self,KiWave)
end

function KiWaveSeg:new(image,kiWave)

end