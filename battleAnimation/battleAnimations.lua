-- battle animations
local gfx = playdate.graphics
local ui = playdate.ui

import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'genData/spriteMetadata'
import 'CoreLibs/timer'
import 'CoreLibs/ui/gridview.lua'
import 'battleAnimation/init'
import 'battleAnimation/cleanup'
import 'battleAnimation/comm'
import 'battleAnimation/fx'
import 'battleAnimation/sprites'
import 'battleAnimation/controller'

local gfx = playdate.graphics
local ui = playdate.ui

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