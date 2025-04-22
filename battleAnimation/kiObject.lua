--kiObject.lua
--for ki blasts and projectiles.

local gfx = playdate.graphics
local ui = playdate.ui

function KiProjectile:new(side, type, name, size, speed, effectTab)
    --type can be underhand, overhand, and fore. 
    local self = gfx.sprite.new()
    setmetatable(self,KiProjectile)
    self.speed = speed or 100 -- default to almost instant.
    self.type = type
    self.name = name
    self.size = size
    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet())
    self:setImage(self.spriteTable[self.tableRef])
    self.dir = self:getDirection()
    self.side = side
    self.effectTab = effectTab
    self.transition = false -- flag for whether or not the transition to the enemy has occured.  
    self.x, self.y = side:getPosition()
    self:add()
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
    if self.dir == "right" then
        self:moveBy(self.speed, 0)
        if self.x > 420 and self.transition == false then
            self.transition = true
            self.effectTab.controller:kiTransition(self)
        end
    elseif self.dir == "left" then
        self:moveBy(-self.speed, 0)
        if self.x < -20 and self.transition == false then
            self.transition = true
            self.effectTab.controller:kiTransition(self) -- transition to defender once the ki object leaves the screen
        end
    end
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
    self.setImage()

    
    self.dir = self:getDirection()
    self.side = side
    self.effectTab = effectTab
    self.x, self.y = side:getPosition()
    self:add()
    self:moveTo(self.x,self.y)
end
