-- battle animations
local gfx = playdate.graphics
local ui = playdate.ui

import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'genData/spriteMetadata'
import 'CoreLibs/timer'
import 'CoreLibs/ui/gridview.lua'

local gfx = playdate.graphics
local ui = playdate.ui

btlSprite = {}
btlSprite.__index = btlSprite

setmetatable(btlSprite, {
    __index = gfx.sprite
})

BattleController = {}
BattleController.__index = BattleController

commandButtons = {}

local animationInterrupts = {
    ["Stage Attacks"] = {"2 Stage Attack", "3 Stage Attack", "4 Stage Attack", "5 Stage Attack", "6 Stage Attack", "7 Stage Attack"},
    ["Defense"] = {"Endurance", "Deflect","Shockwave","Foresight","Instant Transmission","Time Freeze"},
    ["Beam"] = {},
    ["Physical"] = {},
    ["Support"] = {},
    ["Other"] = {},
    ["Transformation"] = {}
}

local genericAnimationTable = { -- shared animation definitions for attacks with many users.
    "Cont. Kick",
    "Cont. Punch",
    "Ki Blast",
    "Ki Wave",
    "Kamehameha",
    "Sword Slash",
    "Pole Strike",
    "Pistol Shot",
    "Endurance",
    "Makoho",
    "Super Kamehameha",
    "stgPrepare",
    "Placeholder"

}

local stageAtkCombos = { -- table of combinations associated with stage attacks. Selected at random.
    ["2 Stage Attack"] = {
        [1] = {"a","a"},
        [2] = {"back", "a"},
        [3] = {"a", "b"},
        [4] = {"b","up"},
        [5] = {"a", "down"},
        [6] = {"back", "b"},
        [7] = {"down", "a"},
        [8] = {"up", "b"},
        [9] = {"up","a"},
        [10] = {"b", "b"}
    },
    ["3 Stage Attack"] = {
        [1] = {"a","a", "b"},
        [2] = {"back", "a", "b"},
        [3] = {"a", "b", "back"},
        [4] = {"b","up","a"},
        [5] = {"a", "down","b"},
        [6] = {"back", "b", "a"},
        [7] = {"down", "a", "a"},
        [8] = {"up", "b", "down"},
        [9] = {"up","a", "back"},
        [10] = {"b", "b", "back"}
    },
    ["4 Stage Attack"] = {
        [1] = {"a","a", "b", "b"},
        [2] = {"back", "a", "b", "down"},
        [3] = {"a", "b", "back", "b"},
        [4] = {"b","up","a", "back"},
        [5] = {"a", "down","b", "a"},
        [6] = {"back", "b", "a", "a"},
        [7] = {"down", "a", "a", "b"},
        [8] = {"up", "b", "down", "b"},
        [9] = {"up","a", "back", "b"},
        [10] = {"b", "b", "back", "a"}
    },
    ["5 Stage Attack"] = {        
        [1] = {"a","a", "b", "b", "a"},
        [2] = {"back", "a", "b", "down","a" },
        [3] = {"a", "a", "a", "b", "back"},
        [4] = {"b","up","a", "back", "down"},
        [5] = {"a", "down","b", "a", "a"},
        [6] = {"back", "b", "a", "a", "back"},
        [7] = {"down", "a", "a", "b", "b"},
        [8] = {"up", "b", "down", "b", "up"},
        [9] = {"up","a", "back", "b", "down"},
        [10] = {"b", "b", "back", "a", "up"}
    },
    ["6 Stage Attack"] = {
        [1] = {"a","a", "b", "b", "a", "up"},
        [2] = {"back", "a", "b", "down","a", "back"},
        [3] = {"a", "a", "a", "b", "back", "b"},
        [4] = {"b","up","a", "back", "down", "a"},
        [5] = {"a", "down","b", "a", "a", "back"},
        [6] = {"back", "b", "a", "a", "back", "b"},
        [7] = {"down", "a", "a", "b", "b", "a"},
        [8] = {"up", "b", "down", "b", "up", "a"},
        [9] = {"up","a", "back", "b", "down", "a"},
        [10] = {"b", "b", "back", "a", "up", "b"}
    },
    ["7 Stage Attack"] = {
        [1] = {"a","up","b","down","back","a","b"},
        [2] = {"a","a","a","a","b","b","up"},
        [3] = {"up","b","a","b","down","a","b"},
        [4] = {"b","a","back","a","b","back","down"},
        [5] = {"up","a","back","b","down","a","back"},
        [6] = {"b","b","a","down","b","back","a"},
    },
}

function clearField() -- function that clears the battle graphics
    SubMode = SubEnum.NONE
    fadeInWhite("normal")
    clearBattleMenus()
    clearBattleFieldSprites()
    clearBottomUIInfo()
    clearStgElements()
    clearBattleSprites()
end

function clearExceptBattleSprites()
    SubMode = SubEnum.NONE
    fadeInWhite("normal")
    clearEffectTimers()
    clearBattleMenus()
    clearBattleFieldSprites()
    clearBottomUIInfo()
    clearStgElements()
end

function clearEffectTimers()
    for i,v in pairs(battleSpriteIndex) do
        for k,c in pairs(v.effectTimers) do
            c:remove()
        end
    end

end

function clearStgElements()
    for i,v in pairs(otherIndex) do
        if v.tag =="timerC" then
            v:spriteKill()
        end
    end
    for i,v in pairs(commandButtons) do
        v:spriteKill()
    end
end

function clearBattleSprites()
    for i,v in pairs (battleSpriteIndex) do
        v:spriteKill()
    end
    battleSpriteIndex["attacker"] = nil
    battleSpriteIndex["defender"] = nil
end

function clearBattleMenus()
    for i,v in pairs(menuIndex) do
        v:spriteKill()
    end
end

function clearBattleFieldSprites()
    for i,v in pairs(sprBIndex) do
        v:spriteKill()
    end
end

function clearBottomUIInfo()
    for i,v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            v:spriteKill()
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

function commandEnter() -- function for entering stage attack commands

    local result = cmdChl() -- returns a table with hits and\or misses and direction\button for each (eg, [1] = {"a",true}, [2] = {"up", false})
    local cmdAnim = getResultSequence(result) -- returns the animation sequence for the results

end

function getResultSequence(table) -- returns a table with animation steps based on the results of command input

end

function loadAnimationTable(attacker, defender) -- runs after clearField. Loads animations to play based on initial execTurn results. 
    local attackName = nil
    local defendName = nil

    for i,v in pairs(attacker.card) do -- if selected attack move warrants player input (eg, card command)
        for j,k in pairs(animationInterrupts["Stage Attacks"]) do
            if v == k then
                attacker.stageInputReq = true
            end
        end
    end

    for i,v in pairs(defender.card) do -- if selected defense move warrants player input (eg, Beam Battle, etc) tbd
        for j,k in pairs(animationInterrupts["Defense"]) do
            if v == k then
                defender.inputReq = true
            end
        end
    end

    if defender.inputReq == false or defender.inputReq == nil then
        defender.inputReq = false
    end

    attackName = attacker.card["cName"]
    defendName = defender.card["cName"]

    local attackerAni, defenderAni = retrieveAnimationSequence(attackName, attacker.stageInputReq, defendName, defender.inputReq)

   -- iterate through defense cards for any inputs that may be needed on the defender's part.
   return attackerAni, defenderAni
end

function retrieveAnimationSequence(attack, stageFlag, defense, defFlag)
    local stageSequence = {}
    local attAnimationTable = {}
    local defAnimationTable = {}
    local defenseSeq = {}

    if stageFlag then
        --stageSequence = getStgSeq(attack)
        attAnimationTable = getStgPrepare()--setStgSeq(stageSequence, "attacker")
    else
        attAnimationTable = getAniSeq(attack, "attacker")
    end

    if defFlag then
        defenseSeq = getDefSeq(defense)
        defAnimationTable = getDefAni(defenseSeq)
    else
        defAnimationTable = getAniSeq(defense, "defender")
    end

    return attAnimationTable, defAnimationTable -- should be in format tab = [chrCode] = {[1]={frame\instruction, delay\time}, etc} 
end

function getDefSeq(def)
    print("Command not yet defined. For defense command inputs")
end

function getDefAni(table)
    print("getDefAni is for returning animation tables similar to how setAniSeq")
end


function getStgSeq(stage)
    local seq = stageAtkCombos[stage]
    local randomIndex = math.random(#seq)
    return seq[randomIndex]
end

function setStgSeq(table, side)
    local chrA = getChar(side)
    local interTab = getStgPrepare() -- first three values should be the pre-cmd entry sequence. 
    local counter = #interTab + 1
    for i,v in pairs(stageAttackAni) do
        for j,k in pairs(table) do
            if i == k then
                interTab[counter] = v
                counter = counter + 1
            end
        end
    end
    local aniTable = {
        [chrA] = interTab
    }
    return aniTable
end

function getStgPrepare()
    for i,v in pairs (characterAnimationTables) do
        if i == "generic" then
            for k,c in pairs (v) do
                if k == "stgPrepare" then
                    return c
                end
            end
        end
    end
end

function getChar(side)
    if side == "attacker" then
        if CurrentPhase == Phase.ATTACK then
            return playerChr.chrCode
        elseif CurrentPhase == Phase.DEFENSE then
            return enemyChr.chrCode
        end
    elseif side == "defender" then
        if CurrentPhase == Phase.ATTACK then
            return enemyChr.chrCode
        elseif CurrentPhase == Phase.DEFENSE then
            return playerChr.chrCode
        end
    end
end

function getCharName(side,chrCode)
    for i,v in pairs(characters) do
        if chrCode == v.chrCode then
            return v.chrName
        end
    end
end

function getAniSeq(move, side)
    local chrA = getChar(side)
    if move == "Guard" then
        return {"Guard"}
    end
    for i,v in pairs(characterAnimationTables) do
        if i == chrA then
            for k,c in pairs(v) do
                if move == k then
                    return c -- should return a table with a sequence of animation frames in a table
                end
            end
        end
    end
end

function animationGo(attacker, defender) -- The main animation subroutine. All animation logic and drawing steps are sequenced in this program
    clearField()
    sideRef = {}
    sideRef.attacker = attacker
    sideRef.defender = defender
    
    local attackerAnimation, defenderAnimation = loadAnimationTable(attacker, defender)
    local attackerSprite = btlSprite:new("attacker",attackerAnimation)
    local defenderSprite = btlSprite:new("defender",defenderAnimation)
    bgChange(BattleRef["arenaParam"].turnField)

    local attMsg = getAttackMessage(attacker)
    local defMsg = getDefenseMessage(defender)
    attackerSprite["card"] = attacker["card"]
    defenderSprite["card"] = defender["card"]

    local battleAniGo = BattleController:new(attackerSprite, attMsg, attacker["card"].cName, defenderSprite, defMsg, defender["card"].cName)
    battleAniGo:start()

    turnFunctionsDuringAnimation(attacker, defender)
end

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
    -- ... other initializations ...
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
            tallyDamage()
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
        tallyDamage()
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



function BattleController:getAttackForAni(att, def)

    local ACard = cardRet(att)
    local DCard = cardRet(def)

    local AType = ACard["cType"]
    local DType = DCard["cType"]

        --[[
    --types--
    CCommand = "command"
    CPhysical = "physical"
    CKi = "ki"
    CEffect = "effect"
    CTrans = "transformation"
    CReady = "ready"
    CPower = "powerup"
    CGuard = "guard"
    ]]

    if AType == CCommand then
        if DType == CEffect then
            return self.cmdVSEff, self.attSpr, self.defSpr
        elseif DType == CGuard or DType == RGuard then
            return self.cmdVSGrd, self.attSpr, self.defSpr
        elseif DType == CCommand then
            return self.cmdVSCmd, self.attSpr, self.defSpr
        elseif DType == DMove then
            return self.cmdVSMov, self.attSpr, self.defSpr
        end
    elseif AType == CPhysical then
        -- Handle physical attack
    elseif AType == CKi then
        -- Handle ki attack
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
    

    function BattleController:defenderTransition()
        clearExceptBattleSprites()
    
        self.attSpr:trigger("off")
        self.defSpr:trigger("on")
    
        local defMsgTimer = playdate.timer.new(2500, function()
            local msgTime = batDialogue:new(self.defMsg)
            local execAni, attTab, defTab = self:getAttackForAni(self.attInt, self.defInt)
            if execAni then
                execAni(self, attTab, defTab) -- Pass self to access methods
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

function BattleController:start()

    local attMsgTimer = playdate.timer.new(2500, function()
        local msgTime = batDialogue:new(self.attMsg)

        self.stepTable = setAttStep(self.attInt)

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
        elseif self.stepTable[1] == "attack" then
            -- Handle attack
        elseif self.stepTable[1] == "support" then
            -- Handle support
        elseif self.stepTable[1] == "powerUp" then
            -- Handle power-up
        elseif self.stepTable[1] == "partnerSwap" then
            -- Handle partner swap
        end
    end)
end

function getStageResults()
    return commandButtonResults
end

function getMoveAnimationType(side,stop)

    local flyParam = "string"
    local chrPos = "string"
    local oppPos = "string"

    if side == "enemy" then
        flyParam = enemyChr["ability"][1] -- because index 1 is where the fly ability is kept.
        chrReference = enemyChr.chrCode
        chrPos = enemySprTab.position
        opponentReference = playerChr.chrCode
        oppPos = playerSprTab.position
    elseif side == "player" then
        flyParam = playerChr["ability"][1]
        chrReference = playerChr.chrCode
        opponentReference = enemyChr.chrCode
        chrPos = playerSprTab.position
        oppPos = enemySprTab.position
    end

    if flyParam == true then
        if chrPos == "airaft" or chrPos == "airfore" then
            if oppPos == "airaft" or oppPos == "airfore" then
                if stop == "stop" then
                    return "flyForwardWithStop"
                else
                    return "flyForward"
                end
            elseif oppPos == "groundfore" or oppPos == "groundaft" then
                if stop == "stop" then
                    return "flyDownWithStop"
                else
                    return "flyDown"
                end
            end
        elseif chrPos == "groundfore" or chrPos == "groundaft" then
            if oppPos == "airaft" or oppPos == "airfore" then
                if stop == "stop" then
                    return "flyUpWithStop"
                else
                    return "flyUp"
                end
            elseif oppPos == "groundfore" or oppPos == "groundaft" then
                if stop == "stop" then
                    return "runForwardWithStop"
                else
                    return "runForward"
                end
            end
        end
        
    elseif flyParam == false then

        if chrPos == "airaft" or chrPos == "airfore" then -- this will never happen
            if oppPos == "airaft" or oppPos == "airfore" then
                return "none"
            elseif oppPos == "groundfore" or oppPos == "groundaft" then
                if stop == "stop" then
                    return "flyDownWithStop`"
                else
                    return "flyDown"
                end
            end
        elseif chrPos == "groundfore" or chrPos == "groundaft" then
            if oppPos == "airaft" then 
                if stop == "stop" then
                    return "jumpForwardWithStop"
                else
                    return "jumpForward"
                end
            elseif oppPos == "airfore" then
                if stop == "stop" then
                    return "jumpUpWithStop"
                else
                    return "jumpUp"
                end
            elseif oppPos == "groundfore" then
                if stop == "stop" then
                    return "runForwardWithStop"
                else
                    return "runForward"
                end
            elseif oppPos == "groundaft" then
                if stop == "stop" then
                    return "dashRunForwardWithStop"
                else
                    return "dashRunForward"
                end
            end
        end
    else
        print("Position or parameter not found in getMoveAnimationType(): ")
        print("flyParam:"..tostring(flyParam))
        print("attacker position: "..chrPos)
        print("opponent position: "..oppPos)
        print("Side that needs animation: "..side)
    end
end

function setAttStep(interrupt)
    for i,v in pairs(animationInterrupts["Stage Attacks"]) do
        if interrupt == v then
            local nk = 10 --where nk is the number of potential stg atk combos in the table for that stg atk
            if v == "7 Stage Attack" then
                nk = 6 -- only 6 for 7 stg
            end
            local varIO = "stg"
            local selectedStg = {}
            local sInt = math.random(1,nk)
            for k,c in pairs(stageAtkCombos[interrupt]) do
                if sInt == k then
                    selectedStg = c
                end
            end
            --uncomment to use hardcoded combo
            --selectedStg = stageAtkCombos[interrupt][8]
            --print("stage combo hard-coded in setAttStep line ~924")
            return {varIO, selectedStg}
        else
            print("Not a Stage Attack. Load normal animation cycle.")
        end
    end
end

function getAttackMessage(attacker)
    local char = getChar("attacker")
    local charName = getCharName("attacker",char)
    local attMsgString = charName.."'s attack: "..attacker["card"].cName
    return attMsgString
end

function getDefenseMessage(defender)
    local char = getChar("defender")
    local charName = getCharName("defender",char)
    local defMsgString = charName.."'s defense: "..defender["card"].cName
    if defender["card"].cName == "Guard" then
        defMsgString = charName.."'s Guard: Squared Off."
    end
    return defMsgString

end

function checkStgCard(card)
    for i,v in pairs(animationInterrupts["Stage Attacks"]) do
        if card == v then
            return true
        end
    end
end
-- objects --

class('fadeBox').extends(gfx.sprite)

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

-- create player and enemy objects from a common sprite class

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
            playdate.timer.new(850,def:playAni("normalStance"))
        end)
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


cmdButton = gfx.sprite:new()

function cmdButton:new(button, number, btlCont)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = cmdButton })
    self.contRef = btlCont

    self.button = button
    self.physicalButton = getPhysicalButton(button)
    self.number = number
    
    self.pressed = false
    self.wrong = false
    self.spriteTable = gfx.imagetable.new("assets/images/cmdIcons")

    self:setCenter(0,0)
    
    self.xPos = 50 + ((self.number * 32)+20)
    self.yPos = 205

    local col,row, col2, row2, col3, row3 = self:assignIcon(self.button)
    self:assignCoords(col,row,col2,row2,col3,row3)

    self:moveTo(self.xPos, self.yPos)
    self:setImage(self.icon)
    self:updateButton()
    
    self.tag = "btnPrompt"
    self:setZIndex(510)

    commandButtons[self.number] = self

    self:add()

    return self
end

function cmdButton:assignCoords(c1,r1,c2,r2,c3,r3)
    self.icon = self.spriteTable:getImage(c1,r1)
    self.iconCorrect = self.spriteTable:getImage(c2,r2)
    self.iconWrong = self.spriteTable:getImage(c3,r3)
end

function getPhysicalButton(button)
    if button == "back" then
        return "right"
    else
        return button
    end
end

function cmdButton:cmdInput(dir)
    local cont = self.contRef
    if dir == self.physicalButton then
        self.pressed = true
        self:setImage(self.iconCorrect)
        cont.commandButtonResults[self.number] = {true,1,self.physicalButton}
    elseif dir ~= self.physicalButton then
        self.pressed = true
        self.wrong = true
        self:setImage(self.iconWrong)
        cont.commandButtonResults[self.number] = {false,0,self.physicalButton}
    end
    return
end

function cmdButton:spriteKill()
    self:remove()
    for i, v in pairs(commandButtons) do
        if v == self then
            commandButtons[i] = nil
        end
    end
end

function cmdButton:updateButton()
    --self:setImage(self.icon)
end

function cmdButton:assignIcon(button)
    if button == "a" then
        return 1,1,1,2,1,3
    elseif button == "b" then
        return 2,1,2,2,2,3
    elseif button == "down" then
        return 3,1,3,2,3,3
    elseif button == "left" then
        return 4,1,4,2,4,3
    elseif button == "up" then
        return 5,1,5,2,5,3
    elseif button == "back" then
        return 6,1,6,2,6,3
    else
        print("Invalid Button in cmdButton:assignIcon")
        return nil
    end
end

saveButton = gfx.sprite:new()

function saveButton:new(buttonTab)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = saveButton })

    self.buttonTab = buttonTab
    self.blockButton = true
    
    self.pressed = false
    self.selected = "str"
    self.wrong = false
    self.spriteTable = gfx.imagetable.new("assets/images/cmdIcons")

    self:setCenter(0,0)

    self.upImage = self.spriteTable:getImage(7,1)
    self.downImage = self.spriteTable:getImage(8,1)
    self:moveTo(184, 50)
    self:setImage(self.upImage)
    
    self.tag = "savePrompt"
    self:setZIndex(510)
    commandButtons["savBtn"] = self
    self:add()
    return self
end

function saveButton:getResults()
    if self.pressed == true then
        if self.wrong == false then
            if self.selected == "a" then
                return "guard"
            elseif self.selected == "b" then
                return "continue"
            end
        elseif self.wrong == true then
            return "wrong"
        end
    elseif self.pressed == false then
        return "wrong"
    end
end

function saveButton:spriteKill()
    self:remove()
    commandButtons["savBtn"] = nil
end

stgCountdown = ui.gridview:new(20, 20)
stgCountdown.__index = stgCountdown
stgCountdown:setNumberOfColumns(1)
stgCountdown:setCellPadding(0, 0, 0, 0)
stgCountdown:setContentInset(0, 0, 0, 0)

function stgCountdown:new(countDown)
    local self = setmetatable(ui.gridview.new(50,30), stgCountdown)
    self:init(countDown)
    return self
end

function stgCountdown:init(countDown)
    local sizeX, sizeY = 100, 15
    local xPos, yPos = 0, 190
    self.sizeX = sizeX
    self.sizeY = sizeY
    self.xPos = xPos
    self.yPos = yPos

    self.initialTime = 0
    self.active = true
    self.startTime = playdate.getCurrentTimeMilliseconds()
    
    -- Ensure displayTime is set correctly
    self.displayTime = countDown

    self:setNumberOfRows(1)
    self:setScrollDuration(0)
    
    self.countSprite = gfx.sprite.new()
    self.countSprite:setCenter(0, 0)
    self.countSprite:setZIndex(610)
    self.countSprite:moveTo(self.xPos, self.yPos)
    self.countSprite:add()

    self.tag = "timerC"

    self.index = #otherIndex + 1
    otherIndex[self.index] = self
end

function stgCountdown:spriteKill()
    self.countSprite:remove()
    for i, v in pairs(otherIndex) do
        if v.tag == "timerC" then
            otherIndex[i] = nil
        end
    end
end

function stgCountdown:timerUpdate()
    --if self.needsDisplay then
        local currentTime = playdate.getCurrentTimeMilliseconds()
        local elapsedTime = currentTime - self.startTime
        local stgImage = gfx.image.new(self.sizeX,self.sizeY,gfx.kColorBlack)
        self.countSprite:moveTo(self.xPos,self.yPos)
        self.initialTime = elapsedTime

        gfx.pushContext(stgImage)
            self:drawInRect(0,0,self.sizeX,self.sizeY)
        gfx.popContext()
        self.countSprite:setImage(stgImage)
        if self.initialTime >= self.displayTime then
            self.active = false
        end
    --end
end

function stgCountdown:drawCell(section, row, column, selected, x, y, width, height)
    gfx.fillRect(self.xPos, self.yPos, self.sizeX, self.sizeY)
    gfx.setFont(sysFNT.smDBFont)
    local fontHeight = gfx.getFont():getHeight()
    
    local dispTime = self.initialTime / 1000
    local fullTime = self.displayTime / 1000
    local text = string.format("%.2f / %.2f", dispTime, fullTime)
    local original_draw_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawTextInRect(text, x, y --[[+ (height / 2 - fontHeight / 2) + 2]], 80, height, nil, truncationString, kTextAlignment.center)
    gfx.setImageDrawMode(original_draw_mode)
end
