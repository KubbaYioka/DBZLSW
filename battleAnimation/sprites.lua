--sprites.lua
--file for the btlSprite class and all its constituent functions
--declared in init.lua

-- create player and enemy objects from a common sprite class

local gfx = playdate.graphics
local ui = playdate.ui

function btlSprite:new(side, aniTable)

    local self = gfx.sprite.new()
    setmetatable(self, btlSprite)

    self.chrCode = getChar(side)
    self.aniTable = aniTable
    self.visible = false

    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet()) 
    self.frameData = self:getFrameData()
    self.currentFrame = {}

    self:moveTo(200,120)
    self.tag = side
    if self.tag == "attacker" then
        self.visible = true
    end
    
    self:setZIndex(85)
    battleSpriteIndex[self.tag] = self
    self:initEffectTimers()

    self:getSideAndAbilities(self.tag)
    self:updateFrame("normalStance")
    
    if self.visible == true then
        self:add()
    end

    local w,h = self:getSize()
    local groupC = 0
    self:setCollideRect(0,0,w,h)
    if self.tag == "attacker" then
        groupC = COLLISION_GROUP.Attacker
    else
        groupC = COLLISION_GROUP.Defender
    end
    self:setGroups{GroupC}
    self:setCollidesWithGroups{COLLISION_GROUP.Ki} -- and possibly the opposite fighter?
    self.collisionResponseType = gfx.sprite.kCollisionTypeOverlap

    return self
end

function btlSprite:getSideAndAbilities(sA)
    if sA == "attacker" and CurrentPhase == Phase.ATTACK then
        self.identity = "player"
        self.abilities = playerChr["ability"]
    elseif sA == "attacker" and CurrentPhase == Phase.DEFENSE then
        self.identity = "enemy"
        self.abilities = enemyChr["ability"]
    elseif sA == "defender" and CurrentPhase == Phase.DEFENSE then
        self.identity = "player"
        self.abilities = playerChr["ability"]
    elseif sA == "defender" and CurrentPhase == Phase.ATTACK then
        self.identity = "enemy"
        self.abilities = enemyChr["ability"]
    end

end

function btlSprite:trigger(onOff)
    if onOff == "on" then
        if self.visible == "true" then
            return
        else
            self.visible = true
            self:add()
        end
    elseif onOff == "off" then
        if self.visible == false then
            return
        elseif self.visible == true then
            self.visible = false
            self:remove()
        end
    end
end

function btlSprite:draw()
    local offsetX = self.shakeOffsetX or 0
    local offsetY = self.shakeOffsetY or 0

    local img = self:getImage()
    if img then
        img:draw(self.x + offsetX, self.y + offsetY)
    end
end

function btlSprite:spriteKill()
    for i, sprite in ipairs(gfx.sprite.getAllSprites()) do
        if getmetatable(sprite) == btlSprite then
            if sprite.effectTimers then
                for effectName, timer in pairs(sprite.effectTimers) do
                    sprite:stopEffect(effectName)
                end
            end
            sprite:remove()
        end
    end
    self:remove()
    table.remove(battleSpriteIndex, self.index)
end

function btlSprite:updateFrame(frameKey)
    local x, y = self:getMatrixCoords(self.frameData[frameKey])
    
    local numColumns = 8
    local index = (y - 1) * numColumns + x

    self.currentFrame = self.spriteTable:getImage(index)
    
    if self.identity == "enemy" then
        self:setImage(self.currentFrame, gfx.kImageFlippedX)
    else
        self:setImage(self.currentFrame)
    end
end

function btlSprite:getMatrixCoords(tab)
    local x = tab[1]
    local y = tab[2]
    return x,y
end

function btlSprite:getSpriteSheet()
    for i,v in pairs(spriteMetadata[self.chrCode]) do
        if i == "image" then
            return v
        end
    end
end

function btlSprite:getFrameData() -- returns matrix values on the sprite sheet
    return spriteMetadata[self.chrCode]
end

function btlSprite:playAni(ani, trigFunction, effectTab)
    print(ani)
    local aniS = characterAnimationTables[self.chrCode][ani] or characterAnimationTables["generic"][ani]
    if not aniS then
        print("Animation not found: " .. tostring(ani) .. " for sprite " .. self.tag)
        if trigFunction then
            trigFunction()
        end
        return
    end
    
    self:runAnimationSequence(aniS, 1, trigFunction, effectTab)
end

function btlSprite:runAnimationSequence(animation, frameIndex, trigFunction, effectTab)
    if frameIndex > #animation then
        if trigFunction then
            trigFunction()
        end
        return
    end

    local frame = animation[frameIndex]

    if type(frame[2]) == "function" then
        frame[2] = frame[2](self)
    end

    if type(frame[1]) == "function" then
        frame[1] = frame[1]()
    end

    self:updateFrame(frame[1])
    if #frame > 2 then
        for i = 3, #frame do
            local effect = frame[i]
            if effect then
                effect(self, animation, frameIndex, trigFunction, effectTab)
            end
        end
    end

    local frameDuration = frame[2]
    if type(frameDuration) == "number" then
        -- Handle standard time-based frame progression
        playdate.timer.performAfterDelay(frameDuration, function()
            self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
        end)
    end
end

function btlSprite:getEndOfAttackSprite()
    --check to see previous HP vs HP lost. Return sprite based on that. Heavy HP loss = more dire sprite
    --self:playAni("recoveryLight")
end

function btlSprite:initEffectTimers()
    self.effectTimers = {}
end

function btlSprite:stopEffect(effectName)
    if self.effectTimers and self.effectTimers[effectName] then
        if effectName == "all" then
            for k,c in pairs(self.effectTimers) do
                k:remove()
                k = nil
            end
        else
            self.effectTimers[effectName]:remove()
            self.effectTimers[effectName] = nil
        end
    end
end

---sprite effect functions---
function btlSprite:moveInDirection(traj, speed, stopLoc)
    local function move()
        local x, y = self:getPosition()
        if stopLoc ~= nil then
            local stopCoord = 1
            if stopLoc == "opponent" then
                for i,v in pairs(battleSpriteIndex) do
                    if v.tag == "defender" then
                        local cX, xY = v:getPosition()
                        if CurrentPhase == Phase.ATTACK then
                            cX = cX - 30
                        elseif CurrentPhase == Phase.DEFENSE then
                            cX = cX + 30
                        end
                        stopCoord = cX
                    end
                end
            elseif stopLoc == "center" then
                if traj == "right" then
                    stopCoord = 200
                elseif traj == "upRight" then
                    stopCoord = 120
                elseif traj == "down" then
                    stopCoord = 120
                end
            end
            if (traj == "right" and stopLoc == "opponent" and x >= stopCoord) or (traj == "left" and stopLoc == "opponent" and x <= stopCoord) then
                self.effectTimers["move"]:remove()

                return
            elseif traj == "down" and stopLoc == "center" and y >= stopCoord then
                self.effectTimers["move"]:remove()

                return
            elseif traj == "upRight" and stopLoc == "center" and y <= stopCoord then
                self.effectTimers["move"]:remove()

                return
            elseif traj == "right" and stopLoc == "center" and x >= stopCoord then
                self.effectTimers["move"]:remove()

                return
            end
        end

        if traj == "right" then
            self:moveTo(x + speed, y)
        elseif traj == "left" then
            self:moveTo(x - speed, y)
        elseif traj == "up" then
            self:moveTo(x, y - speed)
        elseif traj == "down" then
            self:moveTo(x, y + speed)
        elseif traj == "upRight" then
            self:moveTo(x+2,y+speed)
        end
    end

    self.effectTimers["move"] = playdate.timer.new(10, move)
    self.effectTimers["move"].repeats = true
end

function btlSprite:moveInArc(destX, destY, arcHeight, speed, arcDirection, onComplete)
    if self.isMovingInArc then

        return
    end
    self.isMovingInArc = true

    local startX, startY = self:getPosition()
    local distance = math.sqrt((destX - startX)^2 + (destY - startY)^2)
    local steps = distance / speed
    local currentStep = 0

    local function move()
        currentStep = currentStep + 1
        local progress = currentStep / steps

        if progress >= 1 then
            progress = 1
        end

        local newX = startX + (destX - startX) * progress
        local arc = arcHeight * math.sin(progress * math.pi) * arcDirection
        local newY = startY + (destY - startY) * progress - arc

        self:moveTo(newX, newY)

        if progress >= 1 then
            self.isMovingInArc = false
            if self.effectTimers["moveInArc"] then
                self.effectTimers["moveInArc"]:remove()
                self.effectTimers["moveInArc"] = nil
            end

            if onComplete then
                onComplete()
            end
        end
    end

    self.effectTimers["moveInArc"] = playdate.timer.new(40, move)
    self.effectTimers["moveInArc"].repeats = true
end

function btlSprite:movementExec(dir, onComplete)
    if self.isMoving then return end
    self.isMoving = true

    local startX, startY = self:getPosition()
    local dashOffset = 20
    local destX = (self.tag == "enemy") and (startX - dashOffset) or (startX + dashOffset)

    local moveOutDuration = 200  -- Dash time
    local haltDuration    = 100  -- Pause
    local returnDuration  = 300  -- Return time

    -- 1) Dash forward
    local dashTimer = playdate.timer.new(moveOutDuration, 0, 1)
    dashTimer.updateCallback = function(timer)
        local progress = timer.value
        -- Easing
        local easedProgress = 1 - (1 - progress)*(1 - progress)

        -- ** Example: change sprite image ~70% into dash **
        if progress >= 0.7 and not self.hasShiftedImage then
            self.hasShiftedImage = true
            self:updateFrame("flyBack")  -- or any custom frame
        end

        local newX = startX + (destX - startX) * easedProgress
        self:moveTo(newX, startY)
    end
    dashTimer.timerEndedCallback = function()
        -- Once dash is complete, we pause
        playdate.timer.performAfterDelay(haltDuration, function()
            -- 2) Return trip
            local returnTimer = playdate.timer.new(returnDuration, 0, 1)
            returnTimer.updateCallback = function(t)
                local progress = t.value
                local easedProgress = progress * progress  -- Ease in
                -- If you want another image change near the end:
                if progress >= 0.8 and not self.returnShifted then
                    self.returnShifted = true
                    self:updateFrame("normalStance")
                end
                local newX = destX + (startX - destX) * easedProgress
                self:moveTo(newX, startY)
            end

            returnTimer.timerEndedCallback = function()
                -- Reset flags so next dash can reuse them
                self.hasShiftedImage = false
                self.returnShifted   = false
                self.isMoving        = false

                if onComplete then
                    onComplete()
                end
            end
        end)
    end
end

function btlSprite:hitBounce(destX, destY, speed, onComplete)
    if self.isHitBounce then
        return
    end
    self.isHitBounce = true

    local startX, startY = self:getPosition()
    local dx = destX - startX
    local dy = destY - startY

    local distance = math.sqrt(dx*dx + dy*dy)
    local steps = math.floor(distance / speed)
    if steps < 1 then steps = 1 end

    local currentStep = 0

    local function move()
        currentStep = currentStep + 1
        local progress = currentStep / steps
        if progress > 1 then progress = 1 end

        local easedProgress = 1 - (1 - progress)*(1 - progress)

        local newX = startX + dx * easedProgress
        local newY = startY + dy * easedProgress

        self:moveTo(newX, newY)

        if progress >= 1 then
            self.isHitBounce = false
            if self.effectTimers["hitBounce"] then
                self.effectTimers["hitBounce"]:remove()
                self.effectTimers["hitBounce"] = nil
            end
            if onComplete then
                onComplete()
            end
        end
    end
    self.effectTimers = self.effectTimers or {}
    self.effectTimers["hitBounce"] = playdate.timer.new(40, move)
    self.effectTimers["hitBounce"].repeats = true
end

function btlSprite:knockedBack(destTab,speed,spec,onComplete)

    if self.isKnockedBack then
        return
    end
    self.isKnockedBack = true
    local initialX, initialY = self:getPosition()

    local destX = destTab[1]
    local destY = destTab[2]

    local deltaX = destX - initialX
    local deltaY = destY - initialY
    local distance = math.sqrt(deltaX^2 + deltaY^2)
    
    local xDir = deltaX / distance
    local yDir = deltaY / distance
    local xSpeed = xDir * speed
    local ySpeed = yDir * speed

    local function move()
        local currentX, currentY = self:getPosition()

        -- Move the sprite towards the destination
        local newX = currentX + xSpeed
        local newY = currentY + ySpeed

        -- Check if the sprite has reached or passed the destination
        if (xSpeed > 0 and newX >= destX) or (xSpeed < 0 and newX <= destX) then
            newX = destX
        end
        if (ySpeed > 0 and newY >= destY) or (ySpeed < 0 and newY <= destY) then
            newY = destY
        end

        self:moveTo(newX, newY)

        -- Stop the movement when the sprite reaches the destination
        if newX == destX and newY == destY then
            self.isKnockedBack = false
            if self.effectTimers["knockBack"] then
                self.effectTimers["knockBack"]:remove()
                self.effectTimers["knockBack"] = nil
            end
            -- Call the completion callback if provided
            if onComplete then
                onComplete()
            end
        end
    end

    self.effectTimers["knockBack"] = playdate.timer.new(40, move)
    self.effectTimers["knockBack"].repeats = true
end

function btlSprite:comeToStop(destX, destY, speed, onComplete)
    if self.isMovingToStop then
        print("Sprite is already moving to stop. Movement not initiated.")
        return
    end
    self.isMovingToStop = true

    local initialX, initialY = self:getPosition()

    -- Calculate the distance and direction to the destination
    local deltaX = destX - initialX
    local deltaY = destY - initialY
    local distance = math.sqrt(deltaX^2 + deltaY^2)

    -- Normalize the direction vector and scale it by speed
    local xDir = deltaX / distance
    local yDir = deltaY / distance
    local xSpeed = xDir * speed
    local ySpeed = yDir * speed

    local function move()
        local currentX, currentY = self:getPosition()

        -- Move the sprite towards the destination
        local newX = currentX + xSpeed
        local newY = currentY + ySpeed

        -- Check if the sprite has reached or passed the destination
        if (xSpeed > 0 and newX >= destX) or (xSpeed < 0 and newX <= destX) then
            newX = destX
        end
        if (ySpeed > 0 and newY >= destY) or (ySpeed < 0 and newY <= destY) then
            newY = destY
        end

        self:moveTo(newX, newY)

        -- Stop the movement when the sprite reaches the destination
        if newX == destX and newY == destY then
            self.isMovingToStop = false
            if self.effectTimers["comeToStop"] then
                self.effectTimers["comeToStop"]:remove()
                self.effectTimers["comeToStop"] = nil
            end
            -- Call the completion callback if provided
            if onComplete then
                onComplete()
            end
        end
    end

    self.effectTimers["comeToStop"] = playdate.timer.new(40, move)
    self.effectTimers["comeToStop"].repeats = true
end

function btlSprite:opponentHit(btn,btlCont)
    local function startShake(btn, btnTbl)
        for i,v in pairs(battleSpriteIndex) do
            if v.tag == "defender" then
                local duration = 200
                local shake = btnTbl[btn][2] 
                if CurrentPhase == Phase.DEFENSE then
                    shake = shake 
                end
                local originalX, originalY = v:getPosition()
                local offsetX = math.random(0, shake)
                v:playAni(btnTbl[btn][1])
                local shakeTimer = playdate.timer.new(100, function()
                    v:moveTo(originalX + offsetX, originalY)
                end)
                
                shakeTimer.repeats = true
                    
                playdate.timer.new(duration, function()
                    shakeTimer:remove()
                    
                    -- Reset to original position
                    local originalX, originalY = v:getPosition()
                    v:moveTo(originalX - offsetX, originalY)
                end)
            end
        end
    end

    local function stagger()
        local def = battleSpriteIndex["defender"]
        local duration = 800
        local shake = 5
        local slide = 90
        local sInc = 1
        local originalX, originalY = def:getPosition()
        local destX = 1
        if CurrentPhase == Phase.ATTACK then
            destX = originalX + slide
        else
            destX = originalX - slide
        end

        def:playAni("normalHit")

        local function slide()
            local cX, cY = def:getPosition()
            if CurrentPhase == Phase.DEFENSE then
               if  cX >= destX then
                    if cX > destX+50 then
                        def.shakeOffsetX = math.random(-shake, shake)
                        local sBInc = sInc - 5
                        def:moveTo(cX+(sBInc+def.shakeOffsetX),cY)
                    elseif cX <= (destX+50) then
                        def:moveTo(cX-sInc,cY)
                    end
               end
            elseif CurrentPhase == Phase.ATTACK then
                if  cX <= destX then
                    if cX < destX-50 then
                        def.shakeOffsetX = math.random(-shake, shake)
                        def:moveTo(cX+(sInc+5+def.shakeOffsetX),cY)
                    elseif cX >= destX-50 then
                        def:moveTo(cX+sInc, cY)                   
                    end                
                end
            end
        end
        local moveTimer = playdate.timer.new(50, function ()
            slide()
        end)
        moveTimer.repeats = true
        
        playdate.timer.new(duration, function()
            moveTimer:remove()
            playdate.timer.new(850,def:playAni("normalStance")) -- probably default. May need to change based on 
        end)                                                    -- power of a hit
    end

    local function knockOffScreen(btn, btnTbl)
        local def = battleSpriteIndex["defender"]
        local atkr = battleSpriteIndex["attacker"]
        atkr.lastAnim = btn

        if btn == "back" then
            def.lastAnim = "knockBack"
            def:playAni("knockBack")
        elseif btn == "up" then
            def.lastAnim = "knockBackUp"
            def:playAni("knockBackUp")
        elseif btn == "down" then
            def.lastAnim = "knockBackDown"
            def:playAni("knockBackDown")
        end
    end

    atk, def = getHitTables()
    local btn = btn
    local knockBk, btnTable= getPercentageAndFunc(atk["str"],def["def"])
    local controller = btlCont and btlCont.controller

    local atkSpr = controller.attSpr
    local commandButtonResults = controller.commandButtonResults
    if knockBk == "normal" then
        if btn == "a" or btn == "b" then
            if atkSpr.iterator == #commandButtonResults then
                stagger()
            else
                startShake(btn, btnTable)
            end
        elseif btn == "up" or btn == "back" or btn == "down" then

            knockOffScreen(btn,btnTable)
        end
    elseif knockBk ~= "normal" then
        print("Logic for other knockback levels needed here at the end of btlSprite:opponentHit.")
    end
end

function btlSprite:startSprShake(intensity,duration)
    local originalX, originalY = self:getPosition()
    local offsetX = math.random(0, intensity)
    local shakeTimer = playdate.timer.new(100, function()
        self:moveTo(originalX + offsetX, originalY)
    end)
    
    shakeTimer.repeats = true
        
    playdate.timer.new(duration, function()
        shakeTimer:remove()
        -- Reset to original position
        local originalX, originalY = v:getPosition()
        self:moveTo(originalX - offsetX, originalY)
    end)
end

function btlSprite:sprStagger(intensity, distance)
    local originalX, originalY = self:getPosition()
    local destX = 1
    if CurrentPhase == Phase.ATTACK then
        destX = originalX + slide
    else
        destX = originalX - slide
    end
end

function btlSprite:slideBack(intensity, distance, speed)
    print(intensity,distance,speed)
    local shake      = intensity
    local duration   = 800
    local startX, y  = self:getPosition()
    local startY = y
    local destX = distance + startX
    local speed = speed
    local moveTimer

    moveTimer = playdate.timer.new(50, function()
        local x = select(1, self:getPosition())

        if CurrentPhase == Phase.DEFENSE then
            if x > destX then
                x = x - speed
                y = y + shake
                shake = shake * -1
                self:moveTo(x, y)
            else
                moveTimer:remove()
                self:moveTo(x,startY)
                --self:playAni("normalStance")
            end
        else
            if x < destX then
                x = x + speed
                y = y + shake
                shake = shake * -1
                self:moveTo(x, y)
            else
                moveTimer:remove()
                self:moveTo(x,startY)
                --self:playAni("normalStance")
            end
        end
    end)
    moveTimer.repeats = true
end

function btlSprite:punchContact() --may not actually use in the end.
    local controller = self.controller
    local dmg = self.turnOutcome.statHitMiss[1]
    controller:onHitConfirmed(dmg)
end


function btlSprite:knockAwayOff(direction, severity)

    self:playAni("knockBack")
end