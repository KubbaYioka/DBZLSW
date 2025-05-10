--controller.lua
--hosts the class for the BattleController and its attendant functions
--BattleController is declared in init.lua

local gfx = playdate.graphics
local ui = playdate.ui

function BattleController:new(attSpr, attMsg, attInt, defSpr, defMsg, defInt) -- this is a series of carefully timed, nested timers that control the animation sequences.
    local self = setmetatable({},BattleController)
    self.attSpr = attSpr
    self.defSpr = defSpr
    self.attMsg = attMsg
    self.defMsg = defMsg
    self.attInt = attInt
    self.defInt = defInt
    self.stepTable = {}
    self.commandButtonResults = {}
    return self
end

function BattleController:atkOver()
    applyDamage(self.attSpr, self.defSpr, endOfTurn)
end

function BattleController:stgTableIterate(iterator)
    local aniMStep = "string"
    if self.attSpr.iterator == nil then
        self.attSpr.iterator = 1
        self.attSpr.stgHold = false
    end
    if CurrentPhase == Phase.ATTACK then
        if self.commandButtonResults[self.attSpr.iterator][1] == true then
            self.attSpr.ccAdd = (self.attSpr.ccAdd or 0) + 1
            aniMStep = self.commandButtonResults[self.attSpr.iterator][3]
            if aniMStep == "right" then
                aniMStep = "back"
            end
            tallyDamageForStg()
        elseif self.commandButtonResults[self.attSpr.iterator][1] == false then
            print("Attack misses")
            self:missedStg(self.commandButtonResults[self.attSpr.iterator])
            return
        end
    elseif CurrentPhase == Phase.DEFENSE then
        self.attSpr.ccAdd = (self.attSpr.ccAdd or 0) + 1
        local stgTableEne = self.attSpr.stepTable[2]

        aniMStep = stgTableEne[self.attSpr.iterator]

        if aniMStep == "right" then
            aniMStep = "back"
        end
        tallyDamageForStg()
    end
    if aniMStep == "back" or aniMStep == "up" or aniMStep == "down" then
        self.attSpr.stgHold = true
    end
    self.attSpr:playAni(aniMStep, function() self:nextStgAtk() end, {controller=self})
end

function BattleController:missedStg(missedStg) -- prepare for cmd input save. 
    self.attSpr:playAni("normalStance")
    self.defSpr:playAni("normalStance")
    local savBtn = saveButton:new(missedStg)
    SubMode = SubEnum.BTNS
    local saveTime = math.random(150,350) -- savetime is the time in ms before b can be pressed to continue
    local pressTime = getPositionDistance("btn") -- presstime is the number of frames available to press a button
    local readyTimer = playdate.timer.new(saveTime, function() 
        self:missedPress(pressTime)
    end)
end

function BattleController:missedPress(pTime) -- process button press during alotted time
    local savButton = commandButtons["savBtn"]
    savButton.hitButton = true
    savButton:setImage(savButton.downImage)
    local frameWindow = playdate.frameTimer.new(pTime, function ()
        savButton.hitButton = false
        savButton.blockButton = false
        self:processMissedPress()
    end)
end

function BattleController:processMissedPress() -- calculate outcome
    SubMode = SubEnum.NONE
    local result = commandButtons["savBtn"]:getResults()
    commandButtons["savBtn"]:spriteKill()
    local briefPause = playdate.timer.new(200, function ()
         self:executeMissedPress(result)
    end)
end

function BattleController:executeMissedPress(btnResult) -- execute outcome
    if btnResult == "guard" then
        self:cmdBlock()
    elseif btnResult == "continue" then
        self:continueAttack()
    elseif btnResult == "wrong" then
        self:knockAway()
    end
end

function BattleController:cmdBlock()
    self.attSpr:playAni("block", nil, {controller=self})
    self.defSpr:playAni("stgCounter", nil, {controller=self})
    local endTimer = playdate.timer.new(1000, function ()
        self:atkOver()
    end)
end

function BattleController:continueAttack() -- make the first index of the iterator's cmd table true so the attack executes.
    self.commandButtonResults[self.attSpr.iterator][1] = true
    self:stgTableIterate(self.attSpr.iterator)
end

function BattleController:knockAway()
    self.attSpr.ccAdd = 0
    battleSpriteIndex["attacker"].damageApplied = 0
    self.defSpr:playAni("stgParry")
    self.attSpr:playAni("knockAway")
    local endTimer = playdate.timer.new(1000, function ()
        self:atkOver()
    end)
end

function BattleController:nextStgAtk(tik)
    if tik ~= nil and tik == false then
        self.attSpr.stgHold = false
    end

    if self.attSpr.iterator >= #self.commandButtonResults then
        self.attackOver = true --flag to prevent the attacker from moving in upon the final knockback.
        if self.attSpr.stgHold == false then
            self:getMoveForDef(self.defSpr)
        else
            self:getMoveForDef(self.defSpr)
            self:getLastScrn()
        end
        self:atkOver()
    else
        if self.attSpr.stgHold == true then
            self:getMoveForAtkr(self.attSpr)
            self:getMoveForDef(self.defSpr)
            self:getPostKnockBack()
        elseif self.attSpr.stgHold == false then
            self.attSpr.iterator = self.attSpr.iterator + 1
            self:stgTableIterate(self.attSpr.iterator)
        end
    end
end


function BattleController:getMoveForDef(def) -- determines what animation comes next after a knockback
    --introduce attack interrupts here if necessary.
    if def.lastAnim == "knockBack" then
        def.nextAnim = "bigHitBack"
    elseif def.lastAnim == "knockBackDown" then
        def.nextAnim = "bigHitDown" 
    elseif def.lastAnim == "knockBackUp" then
        def.nextAnim = "bigHitUp"
    end

end

function BattleController:getMoveForAtkr(atkr)
    if atkr.abilities[1] == true then
        print("Abilities[1] is true. Placeholder timer in getMoveForAtkr")
        atkr.nextAnim = "jumpForward"
    else
        atkr.nextAnim = "jumpForward"
    end
end

function BattleController:getPostKnockBack()
    self.attSpr:playAni(self.attSpr.nextAnim, nil, {controller=self})
end

function BattleController:stageAttackGo()
    local defender = self.defSpr
    local attacker = self.attSpr
    local oppoX, oppoY = defender:getPosition()
    local dir = "string"
    local stopX = 1
    local atkChrg = "string"

    if CurrentPhase == Phase.DEFENSE then
        stopX = oppoX + 10 -- sprite will stop +10 px to the right of defender sprite
    elseif CurrentPhase == Phase.ATTACK then
        stopX = oppoX - 10 -- sprite will stop 10px to the right of the defender.
    end

    if CurrentPhase == Phase.ATTACK then
        self.attSpr:moveTo(-30, 120)
    else
        self.attSpr:moveTo(430, 120)
    end
    self.attSpr:trigger("on")

    if CurrentPhase == Phase.ATTACK then
        atkChrg = getMoveAnimationType("player", "stop")
        dir = "right"
    elseif CurrentPhase == Phase.DEFENSE then
        atkChrg = getMoveAnimationType("enemy", "stop")
        dir = "left"
    end
    attacker:playAni(atkChrg, function() self:stgTableIterate() end)
end

function BattleController:movementGo(onComplete,moveType)
    if moveType == "forwardMove" then
        self.defSpr:playAni("forwardMove", nil, { controller = self })
    elseif moveType == "backMove" then
        self.defSpr:playAni("backMove", nil, { controller = self })
    else
        print("Error. Movement Type Not Found in movementGo - battleAnimations.lua")
        print("moveType variable is: ",moveType)
    end
end

function BattleController:getNextScrn() -- runs immediately after the attacker leaps\flies\teleports offscreen following a knockback. Triggered by the animation itself as a callback
    local def = self.defSpr
    local xMov = 0
    local yMov = 0
    if def.lastAnim == "knockBack" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = 120
        else
            xMov = 450
            yMov = 120
        end
    elseif def.lastAnim == "knockBackUp" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = 300
        else
            xMov = 250
            yMov = 300
        end
    elseif def.lastAnim == "knockBackDown" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = -120
        else
            xMov = 250
            yMov = -120
        end
    end
    def:moveTo(xMov,yMov)

    def:playAni(def.nextAnim, nil, { controller = self })
end

function BattleController:getLastScrn() -- Get final transition if defender is knocked offscreen or something on 
                                        -- the last cmd strike. Similar to getNextScrn, but allows for extensibility
    local def = self.defSpr             -- without altering getNextScrn
    local atk = self.attSpr
    atk:setVisible(false) -- set attacker's sprite to not be drawn. Will eventually be deleted after atkOvr
    local xMov = 0
    local yMov = 0
    if def.lastAnim == "knockBack" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = 120
        else
            xMov = 450
            yMov = 120
        end
    elseif def.lastAnim == "knockBackUp" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = 300
        else
            xMov = 250
            yMov = 300
        end
    elseif def.lastAnim == "knockBackDown" then
        if CurrentPhase == Phase.ATTACK then
            xMov = -150
            yMov = -120
        else
            xMov = 250
            yMov = -120
        end
    end
    def:moveTo(xMov,yMov)

    def:playAni(def.nextAnim, nil, { controller = self })
end

function BattleController:kiTransition(kiObj)
    self:defenderTransition(kiObj)
    self.stunAppliedThisFrame = false -- set anytime there is a ki attack
    local function computeXTrig(defSpr, kiDir, fraction)
        local defX, defW = defSpr:getPosition(), defSpr:getSize()
        local scrW = 400
        if fraction then
            if kiDir == "left" then
                local dist = scrW - defX
                return defX + dist * (1 - fraction)
            else
                local dist = defX
                return defX - dist * (1 - fraction)
            end
        else
            return (kiDir == "left") and (defX + defW / 2) or  (defX - defW / 2)
        end
    end
    
    playdate.timer.new(3000, function()
        if kiObj.dir == "left" then
            kiObj:moveTo(450, kiObj.y)
        else
            kiObj:moveTo(-50, kiObj.y)
        end

        local animName = self.defSpr.turnOutcome.loadedAnimation
        local fraction = KiObjectRangeTables[animName]

        kiObj.xTrig = computeXTrig(self.defSpr, kiObj.dir, fraction)

        kiObj.status = "inbound"
    end)
end

function BattleController:getDefenseRecoveryAfterCard() -- decides what pose the defender will be in after a card-based attack
        local defStat = 0
        local attStat = 0
        if CurrentPhase == Phase.ATTACK then
            defStat = enemyChr.chrDef
            attStat = playerChr.chrStr
        -- recovery animation is affected by 
        -- the strength of the attacker vs the defense of the defender
        elseif CurrentPhase == Phase.DEFENSE then
            defStat = playerChr.chrDef
            attStat = enemyChr.chrStr
        end
    
        local more = math.max(attStat, defStat)
        local least = math.min(attStat, defStat)
        local prc = (least / more) * 100
    
        local def = self.defSpr
        if prc < 20 then
            -- No recovery needed. Enemy is too weak
            def:playAni("normalStance", nil, { controller = self })
        elseif prc >= 20 and prc < 50 then
            -- slight recovery. Normal Pose
            def:playAni("normalStance", nil, { controller = self })
        elseif prc >= 50 and prc < 120 then
            def:playAni("normalStance", nil, { controller = self })
        elseif prc >= 120 and prc < 170 then
            -- Move obviously hurt the opponent
            def:playAni("normalStance", nil, { controller = self })
        elseif prc >= 170 then
            -- Opponent is reeling from the attack
            def:playAni("normalStance", nil, { controller = self }) 
        end
        local endTimer = playdate.timer.new(1000, function ()
            self:atkOver()
        end)
    end

function BattleController:getAnimationForUnguardedDamage(prct)
    local def = self.defSpr
    print("animations must be defined in getAnimationForUnguardedDamage")
    if prct <= 0.02 then
        return def.currentFrame
    elseif prct > 0.02 and prct <= 0.05 then
        return "flinch"
    elseif prct > 0.05 and prct <= 0.10 then
        return "fivePercentDamage"
    elseif prct > 0.10 and prct <= 0.15 then
        return "tenPercentDamage"
        --bit hit from lsw with onscreen recovery
    elseif prct > 0.15 and prct <= 0.20 then
        return "fifteenPercentDamage"
        --big hit but but recovery happens after knockback
    elseif prct > 0.20 and prct <=0.29 then
        return "twentyPercentDamage"
        --big hit, knockback, visibly injured
    elseif prct > 0.30 then
        return "thirtyPercentDamage"
        --big hit, knockback, smash and tumble into ground
    end
end

function BattleController:getKiStrikeAnimation(kiObj)
    local crntPhase = getPhase()
    local referenceTable = {}
    if crntPhase == "attack" then
        referenceTable = BattleRef.enemyTeamRO
    elseif crntPhase == "defense" then
        referenceTable = BattleRef.playerTeamRO
    end
    local selChr = self.defSpr["chrCode"]
    
    local damage = self.attSpr.turnOutcome.statHitMiss[1]
    local defenderBaseHP = 0

    for i,v in pairs(referenceTable) do
        if referenceTable[i]["chrCode"] == selChr then
            defenderBaseHP = referenceTable[i]["chrHp"]
        end
    end
    return self:getAnimationForUnguardedDamage(damage/defenderBaseHP)
end

function BattleController:kiStrike(kiObj)
    local typeKi = kiObj.type
    if self.defSpr.turnOutcome.loadedAnimation then
        self.defSpr:playAni(self.defSpr.turnOutcome.loadedAnimation,nil,self)
        kiObj.status = "miss"
    else
        local animPass = self:getKiStrikeAnimation(kiObj)
        self.defSpr:playAni(animPass,nil,self)
    end
end

function BattleController:getAtkrMoveIn()
    local atkr = self.attSpr
    local aFly = atkr.abilities[1]
    if aFly then
       if atkr.lastAnim == "back" then
        return ""
       else
        print("no move found in getAtkrMoveIn() in spriteMetaData")
       end
    else
        if atkr.lastAnim == "back" then
            atkr:playAni("jumpOver",function() self:nextStgAtk(false) end, {controller=self})
        elseif atkr.lastAnim == "up" then
            atkr:playAni("jumpOver",function() self:nextStgAtk(false) end, {controller=self})
        elseif atkr.lastAnim == "down" then
            atkr:playAni("jumpOver",function() self:nextStgAtk(false) end, {controller=self})
        end
    end
end

function BattleController:getDefenseRecovery() -- decides what pose the defender will be in after halting from a knockback
print("getDefenseRecovery")
    local defStat = 0
    local attStat = 0
    if CurrentPhase == Phase.ATTACK then
        defStat = enemyChr.chrDef
        attStat = playerChr.chrStr
    -- recovery animation is affected by 
    -- the strength of the attacker vs the defense of the defender
    elseif CurrentPhase == Phase.DEFENSE then
        defStat = playerChr.chrDef
        attStat = enemyChr.chrStr
    end

    local more = math.max(attStat, defStat)
    local least = math.min(attStat, defStat)
    local prc = (least / more) * 100

    local def = self.defSpr

    --local atkrMov = getAtkrMoveIn()

    if prc < 20 then
        -- No recovery needed. Enemy is too weak
        def:playAni("recoveryNormal", nil, { controller = self })
    elseif prc >= 20 and prc < 50 then
        -- slight recovery. Normal Pose
        def:playAni("recoveryNormal", nil, { controller = self })
    elseif prc >= 50 and prc < 120 then
        def:playAni("recoveryNormal", nil, { controller = self })
    elseif prc >= 120 and prc < 170 then
        -- Move obviously hurt the opponent
        def:playAni("recoveryNormal", nil, { controller = self })
    elseif prc >= 170 then
        -- Opponent is reeling from the attack
        def:playAni("recoveryNormal", nil, { controller = self }) 
    end

end

function BattleController:cmdVSGrd()
    if self.defSpr["card"].cType ~= RGuard then
        if self.defInt["cAbility"] == CommandBlock then
            -- Handle command block ability
        end
        -- Iterate to see if the card applies to interfere with cmd
    elseif self.defSpr["card"].cType == RGuard then
        self:stageAttackGo()
    end
end


function BattleController:cmdVSEff()

end

function BattleController:cmdVSCmd()

end

function BattleController:cmdVSMov()
    --printTable(self.defSpr)
    local moveType = self.defSpr["card"]["cName"]

    self:movementGo(function()self.stageAttackGo()end,moveType)
end

function BattleController:kiVSGrd(kiObj)
    local xTrig = 0 -- distance from the kiObject the defender will animate.

    if self.defSpr.turnOutcome.loadedAnimation then
        local guardAni = self.defSpr.turnOutcome.loadedAnimation
        for i,v in pairs(KiObjectRangeTables) do
           -- print(i,v,guardAni)
            if v == guardAni then
                if i == "halfDistance" then --animation begins at half the distance from the edge of the screen to sprite
                    if CurrentPhase == Phase.DEFENSE then
                        local sampX = self.defSpr:getPosition()
                        local scrnWidth = 400
                        local midXSamp = scrnWidth - sampX
                        xTrig = sampX - (midXSamp/2)
                    elseif CurrentPhase == Phase.ATTACK then
                        local sampX = self.defSpr:getPosition()
                        local sprXOffset = self.defSpr:getSize()
                        sampX = sampX + sprXOffset
                        local scrnWidth = 400
                        local midXSamp = scrnWidth - sampX
                        xTrig = sampX + (midXSamp/2)
                    end
                elseif i == "quarterDistance" then
                    if CurrentPhase == Phase.DEFENSE then
                        local sampX = self.defSpr:getPosition()
                        local scrnWidth = 400
                        local midXSamp = scrnWidth - sampX
                        xTrig = sampX - (midXSamp/4)
                    elseif CurrentPhase == Phase.ATTACK then
                        local sampX = self.defSpr:getPosition()
                        local sprXOffset = self.defSpr:getSize()
                        sampX = sampX + sprXOffset
                        local scrnWidth = 400
                        local midXSamp = scrnWidth - sampX
                        xTrig = sampX + (midXSamp/4)
                    end
                end
            end   
        end
    end
    kiObj.xTrig = xTrig 
end

function BattleController:getAttackForAni(att, def, obj)

    local ACard = cardRet(att)
    local DCard = cardRet(def)

    local AType = ACard["cType"]
    local DType = DCard["cType"]

    if AType == CCommand then
        if DType == CEffect then
            self:cmdVSEff()
        elseif DType == CGuard or DType == RGuard then
            self:cmdVSGrd()
        elseif DType == CCommand then
            self:cmdVSCmd()
        elseif DType == DMove then
            self:cmdVSMov()
        end
    elseif AType == CPhysical then
        -- Handle physical attack
    elseif AType == CKi then
        self:kiVSGrd(obj)
    elseif AType == CReady then
        -- Handle ready action
    elseif AType == CTrans then
        -- Handle transformation
    elseif AType == CEffect then
        -- Handle effect
    elseif AType == CPower then
        -- Handle power-up
    end
end
    

function BattleController:defenderTransition(obj)
    --print("DefenderTransition")
    clearExceptBattleSprites()

    self.attSpr:trigger("off")
    self.defSpr:trigger("on")

    playdate.timer.new(2500, function()
        batDialogue:new(self.defMsg)
        if obj then
            self:getAttackForAni(self.attInt, self.defInt, obj)
        else
            self:getAttackForAni(self.attInt, self.defInt)
        end
    end)
end
    

function BattleController:continueAfterSpecialAttack()

end

function BattleController:continueAfterSupportMove()

end

function BattleController:commandButtonResultsInit()
    -- Clear self.commandButtonResults
    if self.commandButtonResults and #self.commandButtonResults > 0 then
        for i, v in pairs(self.commandButtonResults) do
            table.remove(self.commandButtonResults, i)
        end
    end
    self.commandButtonResults = {}

    if CurrentPhase == Phase.DEFENSE then
        local stpTab = self.attSpr.stepTable[2]
        for i, v in pairs(stpTab) do
            self.commandButtonResults[i] = { true, 1, v }
        end
    end
end

function BattleController:compareInputToStageLength()
    if #self.commandButtonResults < #self.stepTable[2] then
        local diff = #self.stepTable[2] - #self.commandButtonResults
        local fin = diff + #self.commandButtonResults
        for n = #self.commandButtonResults + 1, fin do
            self.commandButtonResults[n] = { false, 0, self.stepTable[2][n] }
        end
    elseif #self.commandButtonResults == #self.stepTable[2] then
        return
    else
        print("Error in commandButtonResults length.")
        return
    end
end

function BattleController:enemyCharge()
    local waitTime = getPositionDistance()
    self.commandButtonResults = {}
    self:commandButtonResultsInit()

    local chargeAnimationStartTimer = playdate.timer.new((waitTime - 500), function()
        local chargeAnimation = ""
        if CurrentPhase == Phase.ATTACK then
            chargeAnimation = getMoveAnimationType("player")
        elseif CurrentPhase == Phase.DEFENSE then
            chargeAnimation = getMoveAnimationType("enemy")
        end
        self.attSpr:playAni(chargeAnimation, nil, {controller=self})
    end)

    local defenderTransitionTimer = playdate.timer.new(waitTime, function()
        self:defenderTransition()
    end)
end


function BattleController:continueAfterStgPrep()
    self.commandButtonResults = {}
    self:commandButtonResultsInit()
    for i, v in pairs(self.stepTable[2]) do
        local btn = cmdButton:new(v, i, self)
    end
    SubMode = SubEnum.COMM
    local stgTime = getPositionDistance()
    local stgTimer = stgCountdown:new(stgTime)

    local stgInitTimer = playdate.timer.new(stgTime, function()
        self:compareInputToStageLength()
        SubMode = SubEnum.NONE
        self:defenderTransition()
    end)

    local chargeAnimationStartTimer = playdate.timer.new((stgTime - 500), function()
        local chargeAnimation = ""
        if CurrentPhase == Phase.ATTACK then
            chargeAnimation = getMoveAnimationType("player")
        elseif CurrentPhase == Phase.DEFENSE then
            chargeAnimation = getMoveAnimationType("enemy")
        end
        self.attSpr:playAni(chargeAnimation, nil, {controller=self})
    end)
end

function BattleController:continueAfterKi()

end

function BattleController:getHitOrMissForKi(move)
    local dodgeMoves = {
        "genericAvoiding",
        "jumpUpWithStop",
        "nearDodge"
    }
    for i,v in pairs(dodgeMoves) do
        if move == v then
            return true
        end
    end
    --if no match found
    return false
end

function BattleController:cardGo()
        --[[--card types from cards.lua
        CCommand = "command" 
        CPhysical = "physical"
        CKi = "ki"
        CEffect = "effect"
        CTrans = "transformation"
        CReady = "ready"
        CPower = "powerup"
        CGuard = "guard"
        RGuard = "regGuard"
        DMove = "Movement"
        ]]
    local card = self.stepTable
    if card.cType == CKi then
        self.attSpr:playAni(card.cName,function() self:continueAfterKi() end,{controller=self})
    elseif card.cType == CPhysical then
        self.attSpr:playAni(card.cName,function() self:continueAfterPhysical() end,{controller=self})
    elseif card.cType == CEffect then
        --This may need to be altered based on the current Phase, kinda like how they work in DBZLSW
        self.attSpr:playAni(card.cName,function() self:continueAfterEffect() end,{controller=self})
    elseif card.cType == CTrans then
        self.attSpr:playAni(card.cName,function() self:continueAfterTrans() end,{controller=self})
    elseif card.cType == CReady then
        self.attSpr:playAni(card.cName,function() self:continueAfterReady() end,{controller=self})
    elseif card.cType == CPower then
        self.attSpr:playAni(card.cName,function() self:continueAfterPowerUp() end,{controller=self})
    elseif card.cType == CGuard then
        self.attSpr:playAni(card.cName,function() self:continueAfterGuard() end,{controller=self})
    else

    end
end

function BattleController:start()

    local attMsgTimer = playdate.timer.new(2500, function()
        local msgTime = batDialogue:new(self.attMsg)

        --check the type of card we have. 
        self.stepTable = {}
        for i,v in pairs(animationInterrupts["Stage Attacks"]) do
            if self.attInt == v then
                self.stepTable = setAttStep(self.attInt)
                self.isCMD = true                
            end
        end
        if self.isCMD == false or self.isCMD == nil then
            --self.stepTable = self:cardIdent(self.attInt)
            self.stepTable = cardRet(self.attInt)
        end

        if self.stepTable[1] == "stg" then
            if CurrentPhase == Phase.ATTACK then
                local delMsg = playdate.timer.new(2000, function()
                    for i, v in pairs(menuIndex) do
                        if v.type == "msg" then
                            v:spriteKill()
                        end
                    end
                    local pressDialogue = batDialogue:new("Press: ")

                    self.attSpr:playAni("stgPrepare", function() self:continueAfterStgPrep() end, {controller=self})
                end)
            elseif CurrentPhase == Phase.DEFENSE then
                self.attSpr.stepTable = self.stepTable
                local waitMsg = playdate.timer.new(2000, function()
                    self.attSpr:playAni("stgPrepare", function() self:enemyCharge() end, {controller=self})
                end)
            end
        else
        local compTables = {
            ["attackTypes"] = {"physical","ki"},--these match the string enumerators for card types in cards.lua
            ["defenseTypes"] = {"guard"},
            ["powerTypes"] = {"ready","powerup","transformation"},
            ["effectTypes"] = {"effect"}
            }
            local waitMsg = playdate.timer.new(2000,
            function()
                for i,v in pairs(compTables) do
                    for k,c in pairs(v) do
                        if self.stepTable.cType == c then
                            self:cardGo()
                        end
                    end
                end
            end)
        end
    end)
end

function BattleController:onHitConfirmed(attPower)
    if self.stunAppliedThisFrame then 
        return 

    end
    self.stunAppliedThisFrame = true
    self:applyStunOrKnockBack(attPower)
end

function BattleController:getStunOrKnockBackForAtk(onReady)

    if self.stunAppliedThisFrame then
        if onReady then 
            onReady() 
        end
        return
    end

    local attPower = self.attSpr.turnOutcome.statHitMiss[1] or 0
    self:applyStunOrKnockBack(attPower)
    self.stunAppliedThisFrame = true

    if onReady then 
        onReady() 

    end
end

function BattleController:applyStunOrKnockBack(attPower)
    local attPower = attPower
    local crntPhase = getPhase()
    local refHP = 0 -- the reference HP for the defender. Amount at 100%
    local referenceTable = {}
    local selChr = self.defSpr["chrCode"]

    if crntPhase == "attack" then
        referenceTable = BattleRef.enemyTeamRO
    elseif crntPhase == "defense" then
        referenceTable = BattleRef.playerTeamRO
    end

    for i,v in pairs(referenceTable) do
        if referenceTable[i]["chrCode"] == selChr then
            refHP = referenceTable[i]["chrHp"]
        end
    end
    local prct = attPower/refHP

    --print("prct override in applyStunOrKnockBack")
    --prct = 0.02
    if prct <= 0.01 then
        --print("You managed to singe some of my leg hair.")

    elseif prct > 0.01 and prct <= 0.03 then
        --print("Nice one. That made my arm tingle.")
        self.defSpr:startSprShake(1, 300, function ()
            self:getDefenseRecoveryAfterCard()
        end)

    elseif prct > 0.03 and prct <= 0.08 then
        --print("Looks like you've got some fight in you.")
        self.defSpr:slideBack(2, 5, 1, function ()
                self:getDefenseRecoveryAfterCard()
        end)

    elseif prct > 0.08 and prct <= 0.12 then
        --print("I underestimated you.")
        self.defSpr:slideBack(5, 15, 1, function ()
            self:getDefenseRecoveryAfterCard()
        end)

    elseif prct > 0.12 and prct <= 0.20 then
        --print("Where did you get this power?!")
        self.defSpr:slideBack(2, 25, 1, function ()
            self:getDefenseRecoveryAfterCard()
        end)

    elseif prct > 0.20 and prct <=0.29 then
        --print("Only one hit has made contact...why am I so damaged?!")
        --print("Apply a knockback at this point")
        self.defSpr:slideBack(2, 35, 1, function ()
            self:getDefenseRecoveryAfterCard()
        end)

    elseif prct > 0.30 then
        --print("Boy did anyone get the number on that bus...d-don't worry about me! Heh heh...ugh...")
        self.defSpr:slideBack(3,40,2, function ()
            self:getDefenseRecoveryAfterCard()
        end)

        --print("get knockback at this point")
    end
end