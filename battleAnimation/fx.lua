--fx
--for all fx related to the sprites and transitions.

import 'battleAnimation/kiObject'

local gfx = playdate.graphics
local ui = playdate.ui

FXController = {}
FXController.__index = FXController

function FXController:new()
    local self = setmetatable({}, FXController)
    self.projectiles = {}
    self.activeEffects = {}
    return self
end

function FXController:newKi(attacker, effectTab)
    local x, y = attacker:getPosition()
    local ki = KiProjectile:new(x, y, attacker, effectTab)
    table.insert(self.projectiles, ki)
end

function FXController:update()
    for i, fx in ipairs(self.projectiles) do
        fx:update()
        if fx:isFinished() then
            fx:remove()
            table.remove(self.projectiles, i)
        end
    end
end

function fadeInWhite(duration) -- causes a fade out to white, a pause, and then a fade back in.
    if duration == "normal" then
        local fadeOne = fadeBox(0,40,400,80)
    end
end

function switchBackground() -- function that transitions from the battle background to attack background if needed

end


function drawKi(type) -- drawing of beam attacks and other moves like it.

end

function drawAura(side,type) -- draws an aura around a character

end


class('fadeBox').extends(gfx.sprite) --in progress for fading in and out.

function fadeBox:init()
    fadeBox.super.init(self)
    self:setCenter(0, 0)
    self:moveTo(0, 30)
    self:setZIndex(90 + #otherIndex)
    self.alpha = 0
    self.rectanImage = gfx.image.new(400, 170)
    gfx.pushContext(self.rectanImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, 400, 200)
    gfx.popContext()
    self:setImage(self.rectanImage)
    self.endTimer = playdate.timer.new(0)
    self.endTimer.performAfterDelay(2000,function() self:remove() otherIndex[self.index]:remove() end)
    self.index = #otherIndex + 106
    self.tag = "fadeBox"
    otherIndex[self.index] = self
    self:add()
end