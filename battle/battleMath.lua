--battleMath
--contains various mathematical functions for computing different parameters

function getPositionDistance(savBtn)
    local playerDist = playerSprTab.position
    local enemyDist = enemySprTab.position
    local attackerTime = 2000
    local att = 1
    local def = 1
    local attSpeed = 1
    local defSpeed = 2
    local res = 0
    if CurrentPhase == Phase.ATTACK then
        att = playerDist
        def = enemyDist
        attSpeed, defSpeed = getSpeeds("player")
        res = (attSpeed/defSpeed) * 100

    elseif CurrentPhase == Phase.DEFENSE then
        def = playerDist
        att = enemyDist
        attSpeed, defSpeed = getSpeeds("enemy")
        res = (attSpeed/defSpeed) * 100
    end
    if att == "groundfore" then
        if def == "groundfore" then
            attackerTime = attackerTime + 500
        elseif def == "groundaft" then
            attackerTime = attackerTime - 200
        elseif def == "airfore" then
            attackerTime = attackerTime + 300
        elseif def == "airaft" then
            attackerTime = attackerTime - 400
        end
    elseif att == "groundaft" then
        if def == "groundfore" then
            attackerTime = attackerTime - 200
        elseif def == "groundaft" then
            attackerTime = attackerTime - 700
        elseif def == "airfore" then
            attackerTime = attackerTime - 300
        elseif def == "airaft" then
            attackerTime = attackerTime - 800
        end
    elseif att == "airfore" then
        if def == "groundfore" then
            attackerTime = attackerTime + 300
        elseif def == "groundaft" then
            attackerTime = attackerTime - 400
        elseif def == "airfore" then
            attackerTime = attackerTime + 500
        elseif def == "airaft" then
            attackerTime = attackerTime - 200
        end
    elseif att == "airaft" then
        if def == "groundfore" then
            attackerTime = attackerTime - 300
        elseif def == "groundaft" then
            attackerTime = attackerTime - 800
        elseif def == "airfore" then
            attackerTime = attackerTime - 200
        elseif def == "airaft" then
            attackerTime = attackerTime - 700
        end
    end

    if savBtn == nil then
        local spdFactor = getSpdFactor(res)
        attackerTime = attackerTime + spdFactor
    elseif savBtn == "btn" then
        attackerTime = getSpdFactorForSavBtn(res)
        
    end
    return attackerTime
end

function getSpdFactorForSavBtn(num) -- this returns the number of frames a player has to enter a command to continue an attack
    if num < 50 then
        return 5
    elseif num >= 51 and num <= 60 then
        return 6
    elseif num >= 61 and num <= 75 then
        return 7
    elseif num >= 76 and num <= 90 then
        return 8
    elseif num >= 91 and num <= 110 then
        return 15
    elseif num >= 111 and num <= 120 then
        return 17
    elseif num >= 121 and num <= 130 then
        return 20
    elseif num >= 131 and num <= 145 then
        return 30
    elseif num >= 146 and num <= 160 then
        return 40
    elseif num > 161 then
        return 50
    else
        return 0
    end
end

function getSpeeds(attackerS)
    if attackerS == "player" then
        local sp = playerChr["chrSpd"]
        local ds = enemyChr["chrSpd"]
        return playerChr["chrSpd"], enemyChr["chrSpd"]
    elseif attackerS == "enemy" then
        return enemyChr["chrSpd"], playerChr["chrSpd"]
    end
end

function getSpdFactor(num)
    if num < 50 then
        return -500
    elseif num >= 51 and num <= 60 then
        return -400
    elseif num >= 61 and num <= 75 then
        return -200
    elseif num >= 76 and num <= 90 then
        return -100
    elseif num >= 91 and num <= 110 then
        return 0
    elseif num >= 111 and num <= 120 then
        return 200
    elseif num >= 121 and num <= 130 then
        return 300
    elseif num >= 131 and num <= 145 then
        return 400
    elseif num >= 146 and num <= 160 then
        return 500
    elseif num > 161 then
        return 700
    else
        return 0
    end
end

function calculateDerivedStats(character, phaseType) --pass character name and the phase they are in for appropriate stats
    if phaseType == attack then
        local calcOFF = character.STR + character.KI
        local calcEVA = character.SPD + character.DEF
        return calcOFF, calcEVA
    elseif phaseType == defense then
        local calcMAS = character.STR + character.DEF
        local calcACC = character.SPD + character.KI -- Modify as needed
        return calcMAS, calcACC 
    else
        print("error in battleEngine calculateDerivedStats")
    end
end

function getHitTables()
    local plr = {}
    local ene = {}
    plr["def"] = playerChr["chrDef"]
    plr["str"] = playerChr["chrStr"]
    ene["def"] = enemyChr["chrDef"]
    ene["str"] = enemyChr["chrStr"]

    plr["off"] = playerChr["chrStr"] + playerChr["chrKi"]
    plr["eva"] = playerChr["chrSpd"] + playerChr["chrDef"]
    plr["mas"] = playerChr["chrStr"] + playerChr["chrDef"]
    plr["acc"] = playerChr["chrSpd"] + playerChr["chrKi"]

    ene["off"] = enemyChr["chrStr"] + enemyChr["chrKi"]
    ene["eva"] = enemyChr["chrSpd"] + enemyChr["chrDef"]
    ene["mas"] = enemyChr["chrStr"] + enemyChr["chrDef"]
    ene["acc"] = enemyChr["chrSpd"] + enemyChr["chrKi"]
    if CurrentPhase == Phase.ATTACK then
        return plr, ene        
    elseif CurrentPhase == Phase.DEFENSE then
        return ene, plr
    end
end

function getPositionBonus(side)
    local pTab = nil
    if side == "enemy" then
        pTab = enemySprTab.position
    elseif side == "player" then
        pTab = playerSprTab.position
    end
    local reTab = {}
    if pTab == PositionEnum.GroundAft then
        reTab["Def"] = 0.10
        reTab["KiDef"] = true
    elseif pTab == PositionEnum.GroundFore then
        reTab["Str"] = 0.10
        reTab["KiDef"] = true
    elseif pTab == PositionEnum.AirAft then
        reTab["Def"] = 0.10
        reTab["PhyDef"] = true
    elseif pTab == PositionEnum.AirFore then
        reTab["Ki"] = 0.10
        reTab["PhyDef"] = true
    end
    return reTab
end

function getPercentageAndFunc(atk, def)
    local more = math.max(atk, def)
    local least = math.min(atk, def)
    local prc = (least / more) * 100

    if prc < 20 then
        -- No visible effect from strikes
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 20 and prc < 40 then
        -- only a slight nudge from strikes
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 40 and prc < 50 then
        -- sprite reaction and slight nudge
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 50 and prc < 80 then
        -- sprite reaction and small shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 80 and prc < 120 then
        -- sprite reaction and normal shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
    elseif prc >= 120 and prc < 150 then
        -- sprite reaction and big shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 150 and prc < 170 then
        -- sprite slight knockback, shake, and reaction
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 170 then
        -- each hit knocks the sprite back
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    end
end

local function calculateEvasion(spd,def)
    return math.sqrt(spd + def)
end

function abilityGet() --get abilities for the player.
    local retuTable = {}
    local nameTable = {}
    local portTable = {}
    local pPhase = CurrentPhase
    local pTab = playerChr.ability

    if pPhase == Phase.ATTACK then
        retuTable[1] = 2 -- player will always be able to move. Check for fly later.
        nameTable[1] = "2 Stage Attack" 
        retuTable[2] = 18
        nameTable[2] = "Movement"
        for i,v in pairs(pTab) do
            if pTab[3] == true then
                retuTable[3] = 17
                nameTable[3] = "Focus"
            elseif pTab[4] == true then
                retuTable[3] = 5
                nameTable[3] = "Power Up"
            else
                retuTable[3] = nil
                nameTable[3] = nil
            end
        end
    else
        retuTable[1] = 19 -- guard
        nameTable[1] = "Guard"
        retuTable[2] = 18
        nameTable[2] = "Movement"
    end 
    return retuTable,nameTable,portTable
end

--movement related computations and logic:

function movTabConfig(cPos)
    if cPos == PositionEnum.GroundFore then
        return 150,160
    elseif cPos == PositionEnum.GroundAft then
        return 60,160
    elseif cPos == PositionEnum.AirFore then
        return 150, 70
    elseif cPos == PositionEnum.AirAft then
        return 60, 70
    end
end

function enTest()
    print("Enemy Position Reported as: "..enemySprTab.position)
    print("Player Position Reported as: "..playerSprTab.position)
    if enemySprTab.position == PositionEnum.AirAft or enemySprTab.position == PositionEnum.GroundAft then
        if playerSprTab.position == PositionEnum.AirFore or playerSprTab.position == PositionEnum.GroundFore then
            return true
        end
    else
        return false
    end
end

function compMove(oX,oY,xtra,cPos,cFly)
    if cPos == PositionEnum.GroundAft then
        if  cFly == true then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return  50,50,2,2
        else
            moveUIInfo:new({"GAft","GFore"})
            return 50,140,1,2
        end
    elseif cPos == PositionEnum.AirAft then
        moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
        return 50,50,2,2
    elseif cPos == PositionEnum.GroundFore then
        if  cFly == true and xtra == true then
            moveUIInfo:new({"AAft","AFore","AXtra"},{"GAft","GFore","GXtra"})
            return  50,50,2,3
        elseif cFly == true and xtra == false then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return 50,50,2,2
        elseif cFly == false and xtra == true then
            moveUIInfo:new({"GAft","GFore","GXtra"})
            return 50,140,1,3
        elseif cFly == false and xtra == false then
            moveUIInfo:new({"GAft","GFore"})
            return 50,140,1,2
        end
    elseif cPos == PositionEnum.AirFore then
        if  xtra == true then
            moveUIInfo:new({"AAft","AFore","AXtra"},{"GAft","GFore","GXtra"})
            return  50,50,2,3
        elseif xtra == false then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return 50,50,2,2
        end
    end
    print("Warning: compMove() did not find a matching condition. Returning defaults.")
    return 50, 50, 1, 1 
end

function movDesc(newPos) --return descriptions for the selected slot in moveField
    local retTable = {}
    if newPos[1] == "AAft" then
        retTable[1] = "Defense Up. Phys Defense."
        retTable[2] = "Attack Up. Phys Defense."
        if newPos[3] ~= nil and newPos[3 ]== "AXtra" then
            retTable[3] = "Attack Up. Phys Defense"
        end
    elseif newPos[1] == "GAft" then
        retTable[1] = "Defense Up. Ki Defense."
        retTable[2] = "Attack Up. Ki Defense."
        if newPos[3] ~= nil and newPos[3 ]== "GXtra" then
            retTable[3] = "Attack Up. Ki Defense"
        end
    end
    printTable(retTable)
    return retTable
end

function turnStat(stat,card,side) --gets stats for a side given the current circumstances and selected actions.
    local tempTab = {}

    local pBonus = {}
    if side == "player" then
       pBonus = getPositionBonus("player")
    elseif side == "enemy" then
       pBonus = getPositionBonus("enemy")
    end

    tempTab.hp = stat.chrHp
    tempTab.def = stat.chrDef
    tempTab.spd = stat.chrSpd
    tempTab.str = stat.chrStr
    tempTab.ki = stat.chrKi
    
    --apply positional bonuses
    if pBonus["Def"] then
        --print("pBonus Def")
        tempTab.def = tempTab.def + (tempTab.def * pBonus["Def"])
    elseif pBonus["Str"] then
        --print("pBonus Str")
        tempTab.str = tempTab.str + (tempTab.str * pBonus["Str"])
    elseif pBonus["Ki"] then
        --print("pBonus Ki")
        tempTab.ki = tempTab.ki + (tempTab.ki * pBonus["Ki"])
    end
    
    --apply any defense bonus from position
    if pBonus["KiDef"] then
        --print("pBonus KiDef")
        tempTab.kiDef = true
    elseif pBonus["PhysDef"] then
        --print("pBonus PhysDef")
        tempTab.physDef = true
    end

    --calculate hidden stats
    tempTab.off = tempTab.str + tempTab.ki
    tempTab.eva = calculateEvasion(tempTab.def,tempTab.spd)
    tempTab.mas = tempTab.str + tempTab.def
    if type(card) == "table" then
        tempTab.acc = card.cAccuracy
        tempTab.abi = card.cAbility
        --examine ability
       --[[ local cType = card.cType
        if cType == CPhysical then
            tempTab.str = tempTab.str + card.cPower
        elseif cType == CKi then
            tempTab.ki = tempTab.ki + card.cPower
        elseif cType == CCommand then
            tempTab.str = tempTab.str + (tempTab.str*card.cPower) -- attacks with a command card are always a percentage of the base strength
        elseif cType == CEffect then
            --tempTab = examineEffect(side,tempTab,card)
        elseif cType == CTrans then
            --function applyTrans(trans)
        elseif cType == CReady then
            --function becomeReady(chr)
        elseif cType == cPower then
            --tempTab = powerUp(tempTab)
        end--]]
    end

    --/ofzg```````

    return tempTab

end

function calculateHitChance(accuracy, evasion)
    local minimumHitChance = 1
    local maximumHitChance = 100

    local evasionImpact = evasion > accuracy and (accuracy / evasion) * evasion or evasion
    local hitChance = accuracy - evasionImpact

    hitChance = math.max(minimumHitChance, hitChance)
    hitChance = math.min(maximumHitChance, hitChance)

    return hitChance
end

function attackHits(hitChance)
    local rndChance = math.random(1, 100)
    
    if rndChance <= hitChance then
        return true  -- Attack hits
    else
        return false  -- Attack misses
    end
end

function calcKnockback(offense, mass)
    local percentage = (offense / mass) * 100
    --print("offense of "..offense.." is "..percentage.." percent of mass "..mass)

    if percentage >= 200 then
        return 100
    elseif percentage >= 160 and percentage <= 189 then
        return 80
    elseif percentage >= 130 and percentage <= 159 then
        return 60
    elseif percentage >= 80 and percentage <= 129 then
        return 40
    elseif percentage >= 60 and percentage <= 79 then
        return 20
    elseif percentage >= 50 and percentage <= 59 then
        return 10
    else
        return 0
    end
end

function calculateKnockDamage(atType, stats, scale) -- criticals scale with difference in power
    local stt = nil
    if atType == "command" or atType == "physical" then
        stt = stats.str
    elseif atType == "ki" then
        stt = stats.ki
    end
    local per = scale * .01
    local critDamage = stt * per
    return critDamage
end