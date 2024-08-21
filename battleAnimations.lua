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

function inputInterrupt(table) -- runs if one of the move strings for the player is in a qualifying list. Controls input logic

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

    local battleAniGo = battleSequence(attackerSprite, attMsg, attacker["card"].cName, defenderSprite, defMsg, defender["card"].cName)
    --turnFunctionsDuringAnimation(attacker, defender)
end

function battleSequence(attSpr, attMsg, attInt, defSpr, defMsg, defInt) -- this is a series of carefully timed, nested timers that control the animation sequences.

    --local variables
    local stepTable = {}

    --local functions

    local function getDefenderAniTable()
        if #commandButtonResults > 0 then
            return "stgReady"
        else
            print("Defender anitable will be normal.")
            return
        end
    end

    local function stgTableIterate(iterator)
        local aniMStep = "string"
        
        if iterator == nil then
            iterator = 1
        elseif iterator > #commandButtonResults then
            return
        end
        
        if commandButtonResults[iterator][1] == true then
            aniMStep = commandButtonResults[iterator][3]
            if aniMStep == "right" then
                aniMStep = "back"
            end
        elseif commandButtonResults[iterator][1] == false then
            print("Attack misses")
        end
        
        for i, v in pairs(battleSpriteIndex) do
            if v.tag == "attacker" then
                
                v:playAni(aniMStep, function()
                    stgTableIterate(iterator + 1)
                end)
                return
            end
        end
    end
    

    local function stageAttackGo(attacker, defender)
        local oppoX = 1
        local oppoY = 1
        local dir = "string"
        local stopX = 1
        local atkChrg = "string"
        for i,v in pairs(battleSpriteIndex) do
            
            if v.tag == "defender" then
                oppoX, oppoY = v:getPosition()
            end

            if CurrentPhase == Phase.DEFENSE then
                stopX = oppoX + 10 -- sprite will stop +10 px to the right of defender sprite
            elseif CurrentPhase == Phase.ATTACK then
                stopX = oppoX - 10 -- sprite will stop 10px to the right of the defender.
            end

            if v.tag == "attacker" then
                v:moveTo(-30,120)
                v:trigger("on")
                
                if CurrentPhase == Phase.ATTACK then
                    atkChrg = getMoveAnimationType("player","stop")
                    dir = "right"
                elseif CurrentPhase == Phase.DEFENSE then
                    atkChrg = getMoveAnimationType("enemy","stop")
                    dir = "left"
                end

                v:playAni(atkChrg,stgTableIterate)
            end
        end
    end

    local function cmdVSGrd(attacker, defender)
        if defender.card["cType"] ~= RGuard then
            if defender.card["cAbility"] == CommandBlock then
               
            end
            -- iterate to see if the card applies to interfere with cmd
        elseif defender.card["cType"] == RGuard then
            stageAttackGo(attacker, defender)
        end
    end

    local function cmdVSEff(cmdTable,defCard)

    end

    local function cmdVSCmd(cmdATable,cmdDTable)

    end

    local function getAttackForAni(att, def)
        local attacker = sideRef.attacker
        local defender = sideRef.defender

        local AType = attacker.card["cType"]
        local DType = defender.card["cType"]

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
                return cmdVSEff, attacker, defender
            elseif DType == CGuard or DType == RGuard then
                return cmdVSGrd, attacker, defender
            elseif DType == CCommand then
                return cmdVSCmd, attacker, defender

            end 
        elseif AType == CPhysical then

        elseif AType == CKi then

        elseif AType == CReady then

        elseif AType == CTrans then

        elseif AType == CEffect then

        elseif AType == CPower then

        end

    end

    local function defenderTransition()
        clearExceptBattleSprites()

        for i,v in pairs(battleSpriteIndex) do
            if v.tag == "attacker" then
                v:trigger("off")
            elseif v.tag == "defender" then
                v:trigger("on")
            end
        end

        local defMsgTimer = playdate.timer.new(2500, function()
            local msgTime = batDialogue:new(defMsg)
            local execAni, attTab, defTab = getAttackForAni(attInt, defInt) -- returns a function to be run 
            execAni(attTab,defTab) -- refers to above functions.
        end)

    end

    local function continueAfterSpecialAttack()

    end

    local function continueAfterSupportMove()

    end

    local function commandButtonResultsInit()
        if #commandButtonResults > 0 then
            for i,v in pairs(commandButtonResults) do
                table.remove(commandButtonResults, i)
            end
        end
        commandButtonResults = {}
    end

    local function compareInputToStageLength()
        if #commandButtonResults < #stepTable[2] then
            local diff = #stepTable[2] - #commandButtonResults
            local fin = diff + #commandButtonResults
            for n=#commandButtonResults+1,fin do
                commandButtonResults[n] = {false,0,stepTable[2][n]}
            end
        elseif #commandButtonResults == #stepTable[2] then
            return
        else
            print("Error in commandButtonRestults length.")
            return
        end
    end

    local function continueAfterStgPrep()
        commandButtonResults = {}
        commandButtonResultsInit()
        for i,v in pairs(stepTable[2]) do  
           local btn = cmdButton:new(v,i)
        end
        SubMode = SubEnum.COMM
        local stgTime = 2000
        stgTime = getPositionDistance() -- gets the time the user has to input their stage attack
        local stgTimer = stgCountdown:new(stgTime)

        local stgInitTimer = playdate.timer.new(stgTime, function() --stage Input time
            compareInputToStageLength()
            --printTable(commandButtonResults)
            SubMode = SubEnum.NONE
            defenderTransition()
        end)

        local chargeAnimationStartTimer = playdate.timer.new((stgTime-500), function()
            local chargeAnimation = "string"
            if CurrentPhase == Phase.ATTACK then
                chargeAnimation = getMoveAnimationType("player")
            elseif CurrentPhase == Phase.DEFENSE then
                chargeAnimation = getMoveAnimationType("enemy")
            end
            for i,v in pairs(battleSpriteIndex) do
                if v.tag == "attacker" then
                    v:playAni(chargeAnimation)
                end
            end
        end) 
    end

    local attMsgTimer = playdate.timer.new(2500, function()
        local msgTime = batDialogue:new(attMsg)

        stepTable = setAttStep(attInt)

        if stepTable[1] == "stg" then
            local delMsg = playdate.timer.new(2000, function()
            for i, v in pairs(menuIndex) do
                if v.type == "msg" then
                    v:spriteKill()
                end
            end
            
            local pressDialogue = batDialogue:new("Press: ")
                        
                for i,v in pairs(battleSpriteIndex) do
                    if v.tag == "attacker" then
                        v:playAni("stgPrepare",continueAfterStgPrep)
                    end
                end
            end)

        elseif stepTable[1] == "attack" then -- or whatever

        elseif stepTable[1] == "support" then

        elseif stepTable[1] == "powerUp" then

        elseif stepTable[1] == "partnerSwap" then
            
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
    if CurrentPhase == Phase.ATTACK then
        for i,v in pairs(animationInterrupts["Stage Attacks"]) do
            if interrupt == v then
                local nk = 10
                if v == "7 Stage Attack" then
                    nk = 6
                end
                local varIO = "stg"
                local selectedStg = {}
                local sInt = math.random(1,nk)
                for k,c in pairs(stageAtkCombos[interrupt]) do
                    if sInt == k then
                        selectedStg = c
                    end
                end
                return {varIO, selectedStg}
            else
                print("Not a Stage Attack. Load normal animation cycle.")
            end
        end
    else
        print("return animation only. Leave open for defense cmd inputs. Enemy Attacks")
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
    self.index = #otherIndex + 1
    self.tag = "fadeBox"
    otherIndex[self.index] = self
    self:add()
end

-- create player and enemy objects from a common sprite class

btlSprite = {}
btlSprite.__index = btlSprite

setmetatable(btlSprite, {
    __index = gfx.sprite
})

function btlSprite:new(side, aniTable)

    local self = gfx.sprite.new()
    setmetatable(self, btlSprite)

    self.chrCode = getChar(side)
    self.aniTable = aniTable
    self.visible = false

    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet()) 
    print(self.spriteTable:getLength())
    self.frameData = self:getFrameData()
    self.currentFrame = {}

    self:moveTo(200,120)
    self.tag = side
    if self.tag == "attacker" then
        self.visible = true
    end
    self.index = #battleSpriteIndex + 1
    self:setZIndex(85)
    battleSpriteIndex[self.index] = self
    self:initEffectTimers()

    self:getSide(self.tag)
    self:updateFrame("normalStance")
    if self.visible == true then
        self:add()
    end

    return self
end

function btlSprite:getSide(sA)
    if sA == "attacker" and CurrentPhase == Phase.ATTACK then
        self.identity = "player"
    elseif sA == "attacker" and CurrentPhase == Phase.DEFENSE then
        self.identity = "enemy"
    elseif sA == "defender" and CurrentPhase == Phase.DEFENSE then
        self.identity = "player"
    elseif sA == "defender" and CurrentPhase == Phase.ATTACK then
        self.identity = "enemy"
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
    if self.visible then
       -- self:drawImage(self:getImage(), 0, 0)
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

function btlSprite:playAni(ani,trigFunction)
    local aniS = characterAnimationTables[self.chrCode][ani] or characterAnimationTables["generic"][ani]
    if not aniS then
        --print("animation not found or not yet defined: "..tostring(aniS).." for sprite "..self.tag)
        if type(aniS) == "table" then
            printTable(aniS)
        end
    end
    self:runAnimationSequence(aniS,1,trigFunction)
end

function btlSprite:runAnimationSequence(animation, frameIndex, trigFunction, effectTab)
    if frameIndex > #animation then

        if trigFunction then
            trigFunction()
        end
        return
    end

    local frame = animation[frameIndex]
    self:updateFrame(frame[1])
    if #frame > 2 then
        for i = 3, #frame do
            local effect = frame[i]
            if effect then
                effect(self)
            end
        end
        
    end

    local frameDuration = frame[2]
    playdate.timer.new(frameDuration, function()
        self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
    end)
end

function btlSprite:initEffectTimers()
    self.effectTimers = {}
end

function btlSprite:stopEffect(effectName)
    if self.effectTimers and self.effectTimers[effectName] then
        self.effectTimers[effectName]:remove()
        self.effectTimers[effectName] = nil
    end
end

---sprite effect functions---
function btlSprite:moveInDirection(traj, speed, stopLoc)
    local function move()
        local x, y = self:getPosition()
        if stopLoc ~= nil then
            local stopCoord = 1
            if stopLoc == "enemy" then
                for i,v in pairs(battleSpriteIndex) do
                    if v.tag == "defender" then
                        local cX, xY = v:getPosition()
                        if CurrentPhase == Phase.ATTACK then
                            cX = cX - 30
                        else
                            cX = cX + 30
                        end
                        stopCoord = cX
                    end
                end
            end
            if (traj == "right" and x >= stopCoord) or (traj == "left" and x <= stopCoord) then
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
        end
    end

    self.effectTimers["move"] = playdate.timer.new(10, move)
    self.effectTimers["move"].repeats = true
end

function btlSprite:opponentHit()
    for i,v in pairs()
end

cmdButton = gfx.sprite:new()

function cmdButton:new(button, number)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = cmdButton })

    self.button = button
    self.physicalButton = getPhysicalButton(button)
    self.number = number
    
    self.pressed = false
    self.wrong = false
    self.spriteTable = gfx.imagetable.new("assets/images/cmdIcons")

    self:setCenter(0,0)
    
    self.xPos = 50 + ((self.number * 32)+20)
    self.yPos = 205

    local col,row = self:assignIcon(self.button)

    self.icon = self.spriteTable:getImage(col,row)
    self:moveTo(self.xPos, self.yPos)
    self:setImage(self.icon)
    self:updateButton()
    
    self.tag = "btnPrompt"
    self:setZIndex(510)

    commandButtons[self.number] = self

    self:add()

    return self
end

function getPhysicalButton(button)
    if button == "back" then
        return "right"
    else
        return button
    end
end

function cmdButton:cmdInput(dir)
    if dir == self.physicalButton then
        self.pressed = true
        commandButtonResults[self.number] = {true,1,self.physicalButton}
    elseif dir ~= self.physicalButton then
        self.pressed = true
        self.wrong = true
        commandButtonResults[self.number] = {false,0,self.physicalButton}
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
        return 1,1
    elseif button == "b" then
        return 2,1
    elseif button == "down" then
        return 3,1
    elseif button == "left" then
        return 4,1
    elseif button == "up" then
        return 5,1
    elseif button == "back" then
        return 6,1
    else
        print("Invalid Button")
        return nil
    end
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
        --print("Timer Update - initialTime (ms):", self.initialTime, "displayTime (ms):", self.displayTime)

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
