--A I  T y p e s--

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
    NORMAL = {function() AINormalAttack() end, function() AINormalDefense() end}
}

--NORMAL AI functions--

function AINormalAttack() 

end

function AINormalDefense()

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
