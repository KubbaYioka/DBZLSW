-- -  A I  T y p e s  - --

--AI Enumeration--
AI = {
    NORMAL = "normal"
    ,AGGRESSIVE = "aggressive" -- favors positions closer to their opponent
    ,DEFENSIVE = "defensive" -- favors positions farther from their opponents
    ,MURDEROUS = "murderous" -- will use special attacks whenever possible
    ,COWARDLY = "cowardly" -- will use defensive moves often. Increases based on player's powered up state
    ,CONSERVATIVE = "conservative" -- will save vast amounts of CC for a blitz of special attacks later. The higher CC, the more special moves they will use at once. 
    ,TECHNICAL = "technical" -- will use a combination of powerup cards to boost their stats
    ,HARDHITTER = "hardHitter" -- attempts to defeat their opponent within the first five turns. Becomes normal after that.
}

AIDec = { -- for corresponding decision functions
    NORMAL = {ATTACK = function() AINormalAttack() end, DEFENSE = function() AINormalDefense() end}
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
    retTable.CC = enemyCC
    retTable.teamCnt = #enemyTeam
    return retTable
end

--check reference stats (what they were at the start of the match)

function checkEnRef(statTbl)
    for i,v in pairs(enemyTeamRO) do
        if i.chrCode == statTbl.chrCode then
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

--check Deck (get Deck, iterate through it for a specific parameter)

--check Limit
function checkEnLimit(limitLst)
    local retTable = {}
    for i,v in pairs(enemyTeam) do
        if i.chrCode == limitLst.chrCode then
            retTable = i.limit
        end
    end
    return retTable
end

--check position

--check player position

--check CC (decide what to do based on CC available.)

--choose card 

function chooseCard(priority,secondary) -- priority is the kind of card that the AI prefers with secondary as backup

end

--select card
function selectCard(card) -- use card that has been chosen

end

--NORMAL AI functions--

function AINormalAttack() 
    local cStats = checkEnStats(enemyChr)
    local refStats = checkEnRef(enemyChr)
    local lLimit = nil
    local plrStats = checkPlrStats(playerChr)

    if cStats.ability[2] == true then
        lLimit = checkEnLimit(enemyChr)
    end

   -- if cStats.CC > 
end

function AINormalDefense()
    local cStats = checkEnStats(enemyChr)
    local refStats = checkEnRef(enemyChr)
    local lLimit = nil
    local plrStats = checkPlrStats(playerChr)

    if cStats.ability[2] == true then
        lLimit = checkEnLimit(enemyChr)
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