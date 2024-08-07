-- battle animations

import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'genData/spriteMetadata'
import 'CoreLibs/timer'

local gfx = playdate.graphics
local ui = playdate.ui

local animationInterrupts = {
    ["Stage Attacks"] = {"2 Stage Attack", "3 Stage Attack", "4 Stage Attack", "5 Stage Attack", "6 Stage Attack", "7 Stage Attack"},
    ["Defense"] = {"Beam Block"}
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
    clearBattleSprites()
    clearBottomUIInfo()
end

function clearBattleMenus()
    for i,v in pairs(menuIndex) do
        v:spriteKill()
    end
end

function clearBattleSprites()
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
    
    local attackerAnimation, defenderAnimation = loadAnimationTable(attacker, defender)
    local attackerSprite = btlSprite:new("attacker",attackerAnimation)
    --local defenderSprite = btlSprite:new("defender",defenderAnimation)
    bgChange(BattleRef["arenaParam"].turnField)

    local attMsg = getAttackMessage(attacker)
    local defMsg = "none"

    local battleAniGo = battleSequence(attackerSprite, attMsg, attacker["card"].cName, defenderSprite, defMsg, defender["card"].cName)
    --turnFunctionsDuringAnimation(attacker, defender)
end

function battleSequence(attSpr, attMsg, attInt, defSpr, defMsg, defInt) -- this is a series of carefully timed, nested timers that control the animation sequences.

    --local variables
    local stepTable = {}

    --local functions

    local function continueAfterSpecialAttack()

    end

    local function continueAfterSupportMove()

    end

    local function continueAfterStgPrep()
        for i,v in pairs(stepTable[2]) do  
           local btn = cmdButton:new(v,i)
        end
        local stgTime = 2000
        --get distance time(stgTime) returns table of values for {total time to input, total time until player sprite begins to move offscreen}
        stgTime = getPositionDistance() -- gets the time the user has to input their stage attack

        local stgInitTimer = playdate.timer.new(stgTime, function() --stage Input time

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
            --function to retrieve animation table established earlier. Add or otherwise factor all times for animation. See if player input is necessary.
            --local initAnimation = playdate.timer.new()    
            
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
            
        end
    end)
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

btlSprite = gfx.sprite:new()

function btlSprite:new(side, aniTable)
    local self = gfx.sprite.new(self)
    setmetatable(self, { __index = btlSprite })

    self.chrCode = getChar(side)
    self.aniTable = aniTable
    self.visible = false
    self.spriteTable = gfx.imagetable.new(self:getSpriteSheet()) -- battledamage or transformation sheets can be loaded over this with playdate.graphics.imagetable:load(path) 
    self.frameData = self:getFrameData()
    self.currentFrame = {}

    self:updateFrame("normalStance")
    
    self:moveTo(200,120)
    self.tag = side
    local number = 5
    if side == "attacker" then
        number = number + 5
        self.visible = true
    end
    self.index = #otherIndex + number
    self:setZIndex(self.index)
    battleSpriteIndex[self.index] = self

    self:add()

    return self
end

function btlSprite:drawBtl()
    
end

function btlSprite:updateFrame(frameKey)
    --print("framekey coords: ")
    --printTable(self.frameData[frameKey])

    local x, y = self:getMatrixCoords(self.frameData[frameKey])
    -- Ensure x and y are properly calculated
    --print("Matrix coords:", x, y)

    -- Calculate the index in the imagetable based on the matrix coordinates
    local index = x + (y - 1) * self.spriteTable:getLength()
    --print("Calculated index:", index)

    self.currentFrame = self.spriteTable:getImage(index)
    self:setImage(self.currentFrame)
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

function btlSprite:playAni(ani,trigFunction, ...)
    local aniS = characterAnimationTables[self.chrCode][ani] or characterAnimationTables["generic"][ani]
    if not aniS then
        print("animation not found or not yet defined: "..tostring(aniS))
        if type(aniS) == "table" then
            printTable(aniS)
        end
    end
    local tab = {}
    if ... then
        tab = {...}
    end
    self:runAnimationSequence(aniS,1,trigFunction,tab)
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

    local frameDuration = frame[2] or 500
    playdate.timer.new(frameDuration, function()
        self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
    end)
end

buttonTable = {}

cmdButton = gfx.sprite:new()

function cmdButton:new(button, number)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = cmdButton })

    self.button = button
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

    otherIndex[self.number] = self

    self:add()

    return self
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

