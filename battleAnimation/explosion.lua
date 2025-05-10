--explosion.lua
--for explosions

local gfx = playdate.graphics

ExplosionTables = {
    ["small"] = { --50x50
        [1] = {imageFrames = gfx.imagetable.new('assets/images/battleGraphics/explosionSmallOne'),
            explosion = {1,2},
            fade = {3,6}
        }
    },
    ["moderate"] = { -- 100x100
        [1] = {imageFrames = gfx.imagetable.new('assets/images/battleGraphics/explosionLargeOne'),
            explosion = {1,2},
            fade = {3,6}
        }
    },
    ["large"] = {}, -- 200x200 may clip edge of screen
    ["huge"] = {} -- entire screen?
}

ExplosionStatusEnum = {
    init = "init",
    fade = "fade"
}

function Explosion:new(size,xSpawn,ySpawn,type)
    local self = gfx.sprite.new()
    setmetatable(self,Explosion)
    self.size = size or "size"
    local variantIndex = math.random(1, #ExplosionTables[self.size]) -- certain attacka may have specific variants
    local variant = ExplosionTables[self.size][variantIndex]
    
    self.spriteTable = variant.imageFrames
    self.frame = variant.explosion[1]
    self.explodeRange = variant.explosion
    self.fadeRange = variant.fade
    
    self.phase = "explode"
    self.frameTimer = 0
    self.frameDelay = 2
    
    self:setImage(self.spriteTable[self.frame])
    self.type = type or "none" -- selects a random explosion for size unless number is given.

    self:setZIndex(901)
    self:add()
    self:moveTo(xSpawn,ySpawn)
end

function Explosion:getSpriteSheet()
    local imageNumber = #ExplosionTables[self.size]
    print(imageNumber)
    local selectedIndex = math.random(1,imageNumber)
    print(selectedIndex)
    print(type(ExplosionTables[self.size][selectedIndex]))
    return ExplosionTables[self.size][selectedIndex]
end

--[[function Explosion:draw()
    local img = self:getImage()
    if img then
        img:draw()
    end
end]]

function Explosion:update()
    self.frameTimer = self.frameTimer + 1
    if self.phase == "explode" then
        if self.frameTimer >= self.frameDelay then
            self.frameTimer = 0
            self.frame = self.frame + 1
            if self.frame > self.explodeRange[2] then
                -- transition to smoke fade
                if self.fadeRange then
                    self.phase = "fade"
                    self.frame = self.fadeRange[1]
                    self.frameDelay = 5 -- fade slower
                else
                    self:remove() -- no fade
                    return
                end
            end
            self:setImage(self.spriteTable[self.frame])
        end
    elseif self.phase == "fade" then
        if self.frameTimer >= self.frameDelay then
            self.frameTimer = 0
            self.frame = self.frame + 1
            if self.frame > self.fadeRange[2] then
                self:remove()
                return
            end
            self:setImage(self.spriteTable[self.frame])
        end
    end
end
