-- -  A I  T y p e s  - --

--AI Enumeration--
AI = {
    NORMAL = {"normal", function() AINormalAttack() end, function() AINormalDefense() end}
    ,AGGRESSIVE = "aggressive" -- favors positions closer to their opponent
    ,DEFENSIVE = "defensive" -- favors positions farther from their opponents
    ,MURDEROUS = "murderous" -- will use special attacks whenever possible
    ,COWARDLY = "cowardly" -- will use defensive moves often. Increases based on player's powered up state
    ,CONSERVATIVE = "conservative" -- will save vast amounts of CC for a blitz of special attacks later. The higher CC, the more special moves they will use at once. 
    ,TECHNICAL = "technical" -- will use a combination of powerup cards to boost their stats
    ,HARDHITTER = "hardHitter" -- attempts to defeat their opponent within the first five turns. Becomes normal after that.
}

AIPRIORITY = {
    CCSAVE = "cc"
    ,ATTACK = "attack"
    ,DEFENSE = "defense"
    ,BOOSTSTR = "booststr"
    ,BOOSTDEF = "boostdef"
    ,BOOSTSPD = "boostspd"
    ,BOOSTKI = "boostki"
    ,HP = "hp"
    ,POWERUP = "powerup"
    ,STREADY = "stready"
    ,KILL = "kill"

}

--AI Tasks--

--[[
    1)Gather Info
    2)Interpret Info
    3)Choose Action
]]--

--check stats

function checkEnStats(statTbl) 
    local retTable = statTbl
    retTable.power = enemyPoweredUp
    retTable.ready = enemyStandReady
    retTable.damage = enemyBattleDamaged
    retTable.CC = enemyCC
    retTable.teamCnt = #enemyTeam
    return retTable
end

--check reference stats (what they were at the start of the match) for reference later.

function checkEnRef(statTbl)
    for i,v in pairs(enemyTeamRO) do
        if v.chrCode == statTbl.chrCode then
            retTable = v
        end
    end
    return retTable 
end

--check player state (are they powered up? What about their HP? How many turns since they used a special attack?)

function checkPlrStats(statTbl)
    local retTable = statTbl
    retTable.power = playerPoweredUp
    retTable.ready = playerStandReady
    retTable.damage = playerBattleDamaged
    return retTable
end

--check Limit. Include checks for if limit is available.
function checkEnLimit(limitLst)
    local retTable = {}
    if limitQuery("enemy") == true then -- check to see if limit is available. currently reduncant due to AI checking ability[2]
        for i,v in pairs(enemyTeam) do
            if v.chrCode == limitLst.chrCode then
                retTable = v.limit
            end
        end
        return retTable
    end
end

--check position

--check player position

--check CC (decide what to do based on CC available.)

--choose card 

function chooseCard(priority) -- priority is the kind of card that the AI prefers with secondary as backup

end

function chooseLimit(priority)

end

--select card
function selectCard(card) -- use card that has been chosen

end

function aiGo() -- AI chooses move for their turn
    local typAI = enemyChr.aiType[1]
    local attackFunc = enemyChr.aiType[2]
    local defFunc = enemyChr.aiType[3]
    if CurrentPhase == Phase.ATTACK then 
        defFunc() -- enemy will always do the opposite of the current phase, as that applies to the player only.
    elseif CurrentPhase == Phase.DEFENSE then
        attackFunc()
    end
end

function gatherAllStats()
    local cStats = checkEnStats(enemyChr)
    local refStats = checkEnRef(enemyChr)
    local lLimit = nil
    local plrStats = checkPlrStats(playerChr)

    if cStats.ability[2] == true then
        lLimit = checkEnLimit(enemyChr)
    end

    return cStats,refStats,lLimit,plrStats
end

--NORMAL AI functions--

function AINormalAttack() 
    --print("AINormalAttack Used")
    local enStats, refStats, limitCards, playerInfo = gatherAllStats()
    local priorities = {saveCC(8,enStats)
                        ,useLimit(enStats)
                        ,hpPriority(enStats.chrHp,refStats.chrHp*0.7)
                        --,gather power\ready if CC > #
                        --,use attack if available and CC > #
                        ,enBasicAttack()


                    }
    for _, action in ipairs(priorities) do
        if action ~= "none" then
            
            local moveFunction = action()
            if moveFunction then
                moveFunction()
                return -- Exit the function once a valid move is executed
            end
        end
    end
end

function AINormalDefense()
    print("AINormalDefense Used")
    local enStats, refStats, limitCards, playerInfo = gatherAllStats()
    local priorities = {timeSinceLastSup(4,playerInfo)
                        ,hpPriority(enStats.chrHp,refStats.chrHp*0.5) -- check to see if hp is half of the original value
                        ,statBoost(10,enStats)
                        ,enBasicGuard()
                    }
    for _, action in ipairs(priorities) do
        if action ~= "none" then
            
            local moveFunction = action()
            if moveFunction then
                moveFunction()
                return -- Exit the function once a valid move is executed
            end
        end
    end



end

--AGGRESSIVE AI functions--

function AIAggressiveAttack() 

end

function AIAggressiveDefense()

end

--DEFENSIVE AI functions--

function AIDefensiveAttack() 

end

function AIDefensiveDefense()

end

--MURDEROUS AI functions--

function AIMurderousAttack() 

end

function AIMurderousDefense()

end

--COWARDLY AI functions--

function AICowardlyAttack() 

end

function AICowardlyDefense()

end

--CONSERVATIVE AI functions--

function AIConservativeAttack() 

end

function AIConservativeDefense()

end

--TECHNICAL AI functions--

function AITechnicalAttack() 

end

function AITechnicalDefense()

end

--HARDHITTER AI Functions--

function AIHardHitterAttack()

end

function AIHardHitterDefense()

end

--AI Priority Functions--

-- All priority functions must either execute or return a flag that it cannot be done, or that there is nothing to do.
-- The only exception is the terminal priority. If all other return none, then the last priority must be executed.

function hpPriority(hp,baseHP)

    if hp < baseHP then
        local moveList = nil --function()-- iterate through cards with an effect with ability HpReg
        if move == "none" then
            return "none"
        else
            --do move
        end
    end
end

function statBoost(num,enStats)

    if enStats.CC >= num then
        --search for card with stat boost param
    else
        return "none"
    end 
end

function saveCC(num,enStats) -- where num is the minimum threshhold CC to not do this function save CC either with a card or default to a command card in the deck or in the basic options

    if num > enStats.CC then
        return "none"
    elseif num <= enStats.CC then
        --save CC move
        return --decision
    end
end

function timeSinceLastSup(num,playerInfo) 
    local desc = nil
    if enemyAtkCounter > num and playerInfo.power or playerInfo.ready then
        desc = defGuard(enStats)
        if desc == "none" then
            desc = simpleDefMoveDesc()
        end
    end
    --maybe make it a possibility that the enemy may randomly decide to use a def card.

    local dStatement = nil
    if desc == nil then
        dStatement = "nil"
    end

    return desc -- will return a function or "none"
end

function useLimit(enStats,limit)

    if enStats.power == true or enStats.ready then
    end
    return "none"
end

function defGuard(enStats) -- use card, move to safer location
    local defC = searchType(CEffect)
    local compatC = nil
    local ccAv = nil
    local cMove = nil
    if defC == "none" then
        return "none"
    else
       compatC = cardChrCompat(enStats,defC)
    end
    if compatC == "none" then
        return "none"
    else
        ccAv = ccQualify(enStats,compatC)
    end
    if ccAv == "none" then
        return "none"
    else
        if #ccAV > 1 then
            local cChosen = multiDefCardDesc(enStats,plrStat,ccAV)-- choose which defensive card is best for the situation. Avoiding, shockwave, endurance, etc.
            --return useCard(cChosen)
        else
            -- return useCard(ccAV[1])
        end
    end
end

function harmStat(selStat) -- use effect card on player, where selStat is the desired Stat
    local crdLst = enDeckGet()
end

function useSpecialInDeck(enStats)
end

function enBasicGuard()
    return battleCardConfirm("Guard","enemy")
    -- return guard function.
end

function enBasicAttack()
    -- determine what card is in basic command. Will be 2 Stage for now
    local basCard = "2 Stage Attack"
    return battleCardConfirm(basCard,"enemy")
end

function simpleDefMoveDesc() -- simple random defensive move decision routine
    local function randomize(options)
        local ind = math.random(1, #options)
        return options[ind]
    end
    local options = {"defendPhys", "defendKi"}

    local choice = randomize(options)
    cMove = enemyMove(choice)

    if cMove == "none" then
        return "none"
    else
        return cMove
    end
end

function enemyMove(location)

    local cLoc = enSprTab.position
    if location == "attack" then
        if cLoc == PositionEnum.GroundFore or cLoc == PositionEnum.AirFore then
            return "none"
        else
            --return movement directly in front of current location
        end
    elseif location == "defendKi" then
        if cLoc == PositionEnum.GroundAft then
            return "none"
        else
            -- return movement
        end
    elseif location == "defendPhys" then
        if cLoc == PositionEnum.AirAft then -- or of flight is not available
            return "none"
        else
            --return movement
        end
    end
end

--Search functions for iterating through cards

function enDeckGet() -- retrieve the deck the enemy has.
    local crdLst = {}
    for i,v in pairs(enemyDeck) do
        for k,c in pairs(cards) do
            if v == c.cNumber then
                crdLst[i] = c
            end
        end
    end
    return crdLst
end

function searchType(priority) -- Find card in deck of a certain type

    local crdLst = enDeckGet()
    local priLst ={}
    for i,v in pairs(crdLst) do
        for k,c in pairs(v) do
            if c == priority then -- card with desired type, if any, is added to the list.
                priLst[i] = v
            end
        end
    end 
    if priLst == 0 then
        return "none" -- if no cards have this type, return none.
    else
        return priLst
    end
end

function searchAbility(ability,list) -- search for card of a specific ability

    local cLst = {}
    for i,v in pairs(list) do
        if v.cAbility == ability then
            cLst[i] = v
        end
    end
    if #cLst == 0 then
        return "none"
    else
        return cLst
    end
end

function commandCompare(list) -- compare command cards in desired list and select best one

    local dLst = {}
    for i,v in pairs(list) do
        dLst[i] = v.cCostGain
    end
    local tOne = 0
    local tSel = 0
    for i,v in pairs(dLst) do
        if v > tOne then
            tOne = v
            tSel = i -- selected command card will be the highest CC count
        end
    end
    return list[tSel] -- returns command card with best CC gain.
end

function cardChrCompat(enStats,list) -- checks cards in list to see which ones are compatible with the current chr

    local cLst = {}
    for i,v in pairs(list) do
        if v.cAllowed == AllChrs then
            cLst[i] = v
        elseif type(v.cAllowed) == "table" then
            for k,c in pairs(v.cAllowed) do
                if c == enStats.chrCode then
                    cLst[i] = v
                end
            end
        end
    end
    if #cLst == 0 then
        return "none"
    else
        return cLst
    end
end

function ccQualify(enStats,list) -- check to see if enemy has CC for cards in list. 

    local cLst = {}
    for i,v in pairs(list) do
        if v.cCost <= enStats.CC then
            cLst[i] = v
        end
    end
    if #cLst == 0 then
        return "none"
    else
        return cLst
    end
end


function listCompare(priority,list) -- compare items in returned list to decide on best one.

    local best = 0 -- where best is going to be the highest number associated with the priority
    local iBest = nil --iBest is the index location in list of the best card
    if #list == 1 then
        return list[1]
    else
        for i,v in pairs(list) do
            for k,c in pairs(v) do
                if k == priority then
                    if c > best then
                        iBest = i
                    end
                end
            end
        end
    end
    return list[iBest] 
end

function multiDefCardDesc(enStats,plrStat,list) -- function for deciding on a defense card if multiple are available

    local cLoc = enSprTab.position
    local desc = nil
    if cLoc == PositionEnum.GroundAft or cLoc == PositionEnum.GroundFore then
        desc = searchSubType(CBlock,list)
    end
    if desc == "none" then
        if cLoc == PositionEnum.AirAft or cLoc == PositionEnum.AirFore then
            desc = searchSubType(CAvoid,list)
        end
    end
    if desc == "none" then
        desc = searchSubType(CDefBoost,list)
    end
    if desc == "none" then
        desc = list[1]
    end
    return desc
end