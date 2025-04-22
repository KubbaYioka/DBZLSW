--battleEngine
--root logic for battleEngine system

import 'battle/battleDecks'
import 'battle/battleGlobalInit'
import 'battle/battleIntro'
import 'battle/battleSetup'
import 'battle/battleTurns'
import 'battle/battleUI'
import 'battle/battleSprites'
import 'battle/battleMath'

local gfx = playdate.graphics

------------------
--Action Confirm--
------------------

function movementConfirm(newPos,side)
    local sidePos = "string"
    --[[    PositionEnum = {
        GroundFore = "groundfore"
        ,GroundAft = "groundaft"
        ,AirFore = "airfore"
        ,AirAft = "airaft"]]
    local selectedMovement = "nil" -- Note that there should be multiple options here that take into account whether the chr can fly and where they are in the arena so that there are more animations contingent on movement abilities
    if newPos == "Defense Up. Phys Defense." then
        selectedMovement = "backMove"
        sidePos = PositionEnum.AirAft
    elseif newPos == "Attack Up. Phys Defense." then
        selectedMovement = "forwardMove"
        sidePos = PositionEnum.AirFore
    elseif newPos == "Defense Up. Ki Defense." then
        selectedMovement = "backMove"
        sidePos = PositionEnum.GroundAft
    elseif newPos == "Attack Up. Ki Defense." then
        selectedMovement = "forwardMove"
        sidePos = PositionEnum.GroundFore
    end
    if side == "enemy" then
        enemySprTab.position = sidePos
    elseif side == "player" then
        playerSprTab.position = sidePos
    end
    goOption(selectedMovement, side)
end

function goOption(selOption,side) -- execute selected battle menu command
    battleCardConfirm(selOption,side)
    aiGo() -- perform AI's turn. returns battleCardConfirm
    if CurrentPhase == Phase.ATTACK then
        execTurn(playerTurnTable,enemyTurnTable)
    elseif CurrentPhase == Phase.DEFENSE then
        execTurn(enemyTurnTable,playerTurnTable)
    end
end

function turnFunctionsDuringAnimation(attacker, defender)
    attacker = attWillDamage(attacker) -- for determining hits and effects as well as applying them
    defender = defKind(defender) -- for determining defense type and effects as well as applying them

    if attacker.damageApply ~= nil then
        attacker.cardHitMiss = moveCompare(attacker,defender) -- checks if cards cause hit or miss due to avoiding, block, etc
        attacker.statHitMiss = statCompare(attacker,defender) -- gets a table with damage, if an attack will land, and if knockback happens
    end

    if attacker.offensiveEffect ~= nil or defender.offensiveEffect ~= nil then
        attacker, defender = effectCompare(attacker,defender) -- returns a table with an offensive effect and its number
        -- conditionals for all other moves possible other than attacks. Effects, powerup, ready, partner switch, etc
        attacker, defender = effectHit(attacker, defender) -- returns booleans for if the attack hits. If a card is supposed to be a command card, the player must enter the commands for this to process.
    end

    --cardHitMiss[1] is a boolean for whether or not the card landed a hit or if the opponent's card blocked it
    --cardHitMiss[2] is the stat that is affected by the hit.
    --where atDamage (statusHitMiss[1]) is the numeric value for hp the defender loses
    --attHit (statHitMiss[2]) is a boolean signaling if the attack lands at all
    --and isKnockback (statHitMiss[3]) is a boolean for whether or not this is critical
    --finally, knockbackMulti (statHitMiss[4]) is the amount of damage to add for a crit

    attacker, defender = moveProcessing(attacker, defender)
    print("attack outcome")
    printTable(attacker)
    print("defense outcome")
    printTable(defender)
    return attacker, defender
    -- do any partner switches
end

function ccChange(attacker, defender)
    if CurrentPhase == Phase.ATTACK then
        if attacker.ccAdd ~= nil then
            playerCC = playerCC + attacker.ccAdd
        end
        if defender.ccAdd ~= nil then
            enemyCC = enemyCC + defender.ccAdd
        end
    elseif CurrentPhase == Phase.DEFENSE then
        if attacker.ccAdd ~= nil then
            enemyCC = enemyCC + attacker.ccAdd
        end
        if defender.ccAdd ~= nil then
            playerCC = playerCC + defender.ccAdd
        end
    end
end

function attWillDamage(attacker)
    local card = attacker.card
    local attType = card.cType
    local damageApply = nil
    local willEffect = nil

    if attType == CCommand or attType == CKi or attType == CPhysical then
        damageApply = true
    end
    if attType == CEffect then
        willEffect = true
    end

    attacker.damageApply = damageApply

    attacker.effectApply = willEffect

    attacker = effectProcessing(attacker) --apply effects of card to user, or load them to see if they hit later

    return attacker 
end

function defKind(defender) 
    local card = defender.card
    local defType = card.cType
    local defAbility = card.cAbility
    local willEffect = nil

    if defType == CEffect then
        willEffect = true
    end

    defender.effectApply = willEffect
    defender = effectProcessing(defender)

    return defender
end

function effectProcessing(side)
    local card = side.card
    local cardEffect = card.cType
    local cardAbility = card.cAbility

    if cardEffect == CEffect then
        for i,v in pairs(AbilityTableSelf) do
            if cardEffect == v then
                side = cardAbility(side,card)
                side.selfEffect = true
            end
        end
        for i,v in pairs(OffensiveAbilities) do
            if cardEffect == v then
                side.offensiveEffect = true
            end
        end
    elseif cardEffect == CTrans or cardEffect == CReady or cardEffect == CPower then
        print(tostring(cardEffect).." not yet implemented. side.selfEffect = true")
        side.selfEffect = true
    end
    return side
end

function moveCompare(attacker,defender) -- compare cards to determine hit or miss because of avoiding, block, etc
    local caCard = attacker.card
    local cdCard = defender.card
    local atCardType = caCard.cType
    local deCardType = cdCard.cType

    local wOutCome = nil
    local kindOfHit = nil
    local retTable = {}
    if attacker.damageApply then 
        if atCardType == CKi then
            kindOfHit = "ki"
        elseif atCardType == CPhysical then
            kindOfHit = "phys"
        elseif atCardType == CCommand then
            kindOfHit = "com"
        end
        if defender.willBlock ~= nil then
            if attacker.breakBlock then
                -- breakBlock. Ignore all willBlock
                wOutCome = true
            else
                if defender.willBlock == "ki" then
                    if atCardType == CKi then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                elseif defender.willBlock == "phys" then
                    if atCardType == CPhysical then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                elseif defender.willBlock == "com" then
                    if atCardType == CCommand then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                end
            end
        else 
            wOutCome = true
        end
    end
    
    retTable = {wOutCome, kindOfHit}

    return retTable
end

function effectCompare(attacker,defender) -- compare cards to determine hit or miss because of avoiding, block, etc
    local caCard = attacker.card
    local cdCard = defender.card
    local attackerEffOffense = {}
    local defenderEffOffense = {}

    if attacker.offensiveEffect == true then
        attackerEffOffense = card.cAbility(defender,card) -- will return stat and how much to change it by
    else
        attackerEffOffense = nil
    end
    if defender.offensiveEffect == true then
        defenderEffOffense = card.cAbility(attacker,card)
    else
        defenderEffOffense = nil
    end

    attacker.EffOffense = attackerEffOffense
    defender.EffOffense = defenderEffOffense

    return attacker, defender
end

function statCompare(attacker,defender)
    local atStat = attacker.mStats
    local deStat = defender.mStats
    local cacKind = attacker.card
    local atKind = cacKind.cType
    local attackKind = nil -- This will eventually be the users power + the power of the card
    local retTable = {}
    if atKind == CKi then
        attackKind = atStat.ki + cacKind.cPower -- individual branches in case anything extra should be done per attack
    elseif atKind == CPhysical then
        attackKind = atStat.str + cacKind.cPower
    elseif atKind == CCommand then
        local ccPwr = atStat.str * cacKind.cPower
        attackKind = atStat.str + ccPwr
    end
    local atDamage = attackKind - deStat.def -- and this is the attack minus the target's defense

    local hitToEvasionChance = calculateHitChance(atStat.acc, deStat.eva)

    local attHit = attackHits(hitToEvasionChance) -- boolean for if the attack has landed

    local knockbackChance = calcKnockback(atStat.off,deStat.mas)
    local isKnockback = attackHits(knockbackChance)

    local knockbackMulti = nil
    if isKnockback == true then
        knockbackMulti = calculateKnockDamage(atKind, atStat, knockbackChance)
    end

    -- at this point, we have determined the amount of damage an attack will cause
    -- as well as whether or not the attack will hit, and if it will cause knockback and if so, how much damage
    retTable = {atDamage,attHit,isKnockback,knockbackMulti}

    return retTable

end

function effectHit(attacker, defender)
    local atStat = attacker.mStats
    local deStat = defender.mStats
    local cacKind = attacker.card
    local cdcKind = defender.card

    if attacker.EffOffense ~= nil then
        local atHitToEvasionChance = calculateHitChange(atStat.acc, deStat.eva)
        local attHit = attackHits(atHitToEvasionChance)
        if attHit == true then
            --print("Attacker's Effect Has Hit!")
            attacker.effecthits = true
        else
            --print("Attacker's Effect Has Missed!")
            attacker.effectHits = false
        end
    end

    if defender.EffOffense ~= nil then
        local deHitToEvasionChance = calculateHitChange(deStat.acc, atStat.eva)
        local deHit = attackHits(atHitToEvasionChance)
        if deHit == true then
            --print("Defender's Effect Has Hit!")
            defender.effectHits = true
        else
            --print("Defender's Effect Has Missed!")
            defender.effectHits = false
        end
    end

    return attacker, defender
end

function moveProcessing(atta, defe)
    --[[
    print("Move Processing")
    print("atta table: ")
    printTable(atta)
    print("------------")
    print(" ")
    print("defe table: ")
    printTable(defe)
    print("------------")
    print(" ")
    --]]
    local attackerMovement = false
    local defenderMovement = false
    if atta.card[cType] == DMove then
        attackerMovement = true
    end
    if defe.card[cType] == DMove then
        defenderMovement = true
    end

    local cardHitTable = atta.cardHitMiss
    local statHitTable = atta.statHitMiss
    local attackerEffect = atta.EffOffense -- not for damage, but for stat changes.
    local defenderEffect = defe.EffOffense -- check correctness
    local deStat = defe.mStats
    local atStat = atta.mStats
    --[[
    print("attHit:")
    print(tostring(statHitTable.attHit))
    print("----------------------")
    print("cardHitTable. Generated by moveCompare. Should have {wOutCome, kindOfHit}")
    print("wOutcome = boolean. kindOfHit = string.")
    for i,v in pairs(cardHitTable) do
        print("index: "..i.." value: "..tostring(v))
    end
    
    print("----------------------")
    print("statHitTable. Generated by statCompare. Should have {atDamage,attHit,isKnockback,knockbackMulti} or {atDamage,attHit,isKnockback} if isKnockback == false")
    print("atDamage is a number. The next two are booleans. The last is the crit multiplier if knockback happens")
    for i,v in pairs(statHitTable) do
        print("index: "..i.." value: "..tostring(v))
    end
    print("----------------------")
    ]]
    
    local cardHit = cardHitTable[1] -- boolean for if the attack lands
    local hitType = cardHitTable[2] -- string for stat that is affected by the hit
    local damageAmount = statHitTable[1] --number   
    local statHit = statHitTable[2] -- boolean
    local knockbackHit = statHitTable[3] --boolean
    local knockbackDamage = statHitTable[4] -- amount

    cardHit = true
    statHit = false

    if cardHit == true and statHit == true then -- conditionals for getting the dodge type if any
        --print("attack hit in eval")
        if knockbackHit == true then
            damageAmount = damageAmount + knockbackDamage
        end

        deStat.hp = deStat.hp - damageAmount
    elseif cardHit == false and statHit == true then
        print("Attack has failed due to Defender's Card. Load appropriate defense animation and stat changes.")
        --defe.dodgeType = getCardDodgeType()
    elseif cardHit == true and statHit == false then
        defe.dodgeType = calculateDodgeType(defe,atta,hitType) --returns type of dodge, the damage to be applied after the dodge, and the percent of the original damage mitigated.
    else
        defe.dodgeType = calculateDodgeType(defe,atta,hitType,"criticalMiss")
        print("Complete miss. Maybe implement a 'critical miss' in the form of a counter or deflection?")
        print("Regardless, the card's function takes precedent.")
    end
    local dodgeTable = {} 
    if defe.dodgeType then
        dodgeTable = defe.dodgeType 
        atta.statHitMiss[1] = dodgeTable[2] --attacker's damage now matches damageC from the calculateDodgeType
    end
    local hitStatTable = {cardHit, statHit, damageAmount, knockbackHit, knockbackDamage, dodgeTable}
    defe.loadedAnimation = getDefenseAnimation(defe,atta,hitType,hitStatTable)

    if atta.offensiveEffect == true then -- apply changes to defender's stats if true, Not for HP!
        for i,v in pairs (deStats) do
            if v == attackerEffect.stat then
                v = v - attackerEffect.num
            end
        end
    end

    defe.mStats = deStat

    if defe.offensiveEffect == true then -- apply changes to attacker's stats if true
        for i,v in pairs (atStats) do
            if v == defenderrEffect.stat then
                v = v - defenderEffect.num
            end
        end
    end

    atta.mStats = atStat
    tallyDamageForAtk()
    return atta, defe
end

function newHPStats(original,turnStats)
    original.chrHp = turnStats.hp
    return original
end

function fullHand(execItem) --where execItem is the o.parentItem to be used after a card is discarded
    SubMode = SubEnum.DIAG
    local tossCheck = false

    batDialogue:new("fullHand")

    playerTemp = execItem

end

function tallyDamageForStg()
    local crd = {}
    local attacker = {}
    local defender = {}
    if CurrentPhase == Phase.ATTACK then
        crd = playerTurnTable.card
        attacker = playerTurnTable
        defender = enemyTurnTable
    elseif CurrentPhase == Phase.DEFENSE then
        crd = enemyTurnTable.card
        attacker = enemyTurnTable 
        defender = playerTurnTable
    end

    local damage = 0
    local stgFlag = false

    damage = crd.cPower * attacker["mStats"]["str"]
    if battleSpriteIndex["attacker"].damageApplied == nil then --unsure if damage for stage attacks is contingent on the number of landed strikes. It should be.
        battleSpriteIndex["attacker"].damageApplied = 0
    end
    battleSpriteIndex["attacker"].damageApplied = battleSpriteIndex["attacker"].damageApplied + damage

end

function tallyDamageForAtk()
    local crd = {}
    local attacker = {}
    local defender = {}
    if CurrentPhase == Phase.ATTACK then
        crd = playerTurnTable.card
        attacker = playerTurnTable
        defender = enemyTurnTable
    elseif CurrentPhase == Phase.DEFENSE then
        crd = enemyTurnTable.card
        attacker = enemyTurnTable 
        defender = playerTurnTable
    end

    local damage = attacker.statHitMiss[1]
    battleSpriteIndex["attacker"].damageApplied = damage
end


function applyDamage(attackerTable, defenderTable, nFunc)
    if attackerTable.damageApplied == nil then
        attackerTable.damageApplied = 0 -- this occurs when the attacker fails to execute any stg attacks. Due to foresight or error on their part.
    end
    local defLife = {}
    if CurrentPhase == Phase.ATTACK then
        defLife = lifeBarIndex["enemyHP"]
    else 
        defLife = lifeBarIndex["playerHP"]
    end
    if attackerTable.damageApplied ~= 0 then
        defLife:damage(attackerTable.damageApplied,nFunc)
    else
        defLife:damage(0,nFunc)
    end
end

function tossCard(item)
    local remCard = cardRet(item)
    for i,v in pairs(playerDeck) do
        if remCard.cNumber == v then -- will remove the first card with the same cNumber in playerDeck. This means that if there are two identical cards, the first one found will be removed.
            table.remove(playerDeck,i)
        end
    end
    for i,v in pairs(menuIndex) do
        if v.tag == "tossSelect" then
            v:spriteKill()
            menuIndex[i] = nil
        end
    end
    goOption(playerTemp, "player")
    playerTemp = nil
    return 0
end

function calculateDodgeType(def, att, attType,crit)

    local selectedGroup = getMissGroup(def,att)
    local dodgeType = getMissSubtype(def,att,selectedGroup)
    -- at this point, we have the type of dodge. Next we need to determine the
    -- amount of damage, and CC gain for hit if any. Other factors such as power differences, speeds, etc
    -- may be used for calculating other things such as visual effects like 
    -- "stun" jitter or slide upon block or whatever.

    local damageC = 0
    local dodgeType = "string"
    local dodgePct = 0 -- may ultimately not need this.
    if selectedGroup == "block" then
        damageC = calcBlockDamage(def,att,attType,crit)
        dodgeType = "block"
    elseif selectedGroup == "counter" then
        print("Counter not yet implemented")
        --local counterType = calcCounterType(def,att,crit)
        --dodgeType = counterType
    elseif selectedGroup == "dodge" then
        dodgeType, damageC, dodgePct = calcDodgeType(def,att,attType,crit)
    end

    return {dodgeType,damageC,dodgePct}    
end