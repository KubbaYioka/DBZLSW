--battleTurns
--this file manages all turn and phase changes.

function initTurn(playerChr,enemyChr)
    local chrGo = nil
    if playerChr.chrSpd > enemyChr.chrSpd then
        chrGo = "player"
    elseif playerChr.chrSpd < enemyChr.chrSpd then
        chrGo = "enemy"
    elseif playerChr.chrSpd == enemyChr.chrSpd then
        if playerChr.chrKi >= enemyChr.chrKi then
            chrGo = "player"
        else
            chrGo = "enemy"
        end
    end
    print("Player Speed = "..playerChr.chrSpd)
    print("Enemy Speed = "..enemyChr.chrSpd)
    if chrGo == "player" then
        turnInc()
        return Phase.ATTACK
    elseif chrGo == "enemy" then
        turnInc()
        return Phase.DEFENSE
    end
end

function turnInc() -- increments the current turn number. 
    CurrentTurn = CurrentTurn + 1
    PhaseTrig = false
end

function nextPhase()
    turnTableClear()
    clearField()
    local enSprite = BattleMiniSpr("enemy")
    local plrSprite = BattleMiniSpr("player")
    bgChange(BattleRef["arenaParam"].bField)
    phaseCheck() -- check to see if a new turn begins and draw one card if available
    CurrentPhase = phaseChange()

    --if new turn, then do the speed check again
    for i,v in pairs(menuIndex) do
        v:spriteKill()
        menuIndex[i] = nil
        if v.tag == "optionSelect" then
            v:spriteKill()
        end
    end
    for i,v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            v:spriteKill()
            UIIndex[i] = nil
        end
    end

    local battleSMenu battleUIMenu:new(phase)

    SubMode = SubEnum.MENU

end

function phaseCheck()
    if PhaseTrig == false then
        PhaseTrig = true
        return 0
    elseif PhaseTrig == true then
        turnInc()
        PhaseTrig = false
        drawCard()
        return 0
    end
end

function phaseChange()
    local cPhase = CurrentPhase
    if cPhase == Phase.ATTACK then
        cPhase = Phase.DEFENSE
    elseif cPhase == Phase.DEFENSE then
        cPhase = Phase.ATTACK
    end
    return cPhase
end

function turnTableClear() --clears these tables for repopulation each turn.
    enemyTurnTable = nil
    playerTurnTable = nil
    attacker = nil
    defender = nil
end

function endOfTurn()
    local attacker = battleSpriteIndex["attacker"]
    local defender = battleSpriteIndex["defender"]
    ccChange(attacker,defender)
    postTurn(attacker, defender)
end

function execTurn(attacker,defender)
    local defType = defender.card
    local attType = attacker.card
    local knockbackDamage = nil
    animationGo(attacker,defender) -- triggers everyhing in the animation part of the turn
end

function postTurn(attacker,defender)    
    local timerPT = playdate.timer.new(1000, function() 
        nextPhase()
    end)
    -- if it is a new turn, set any temporary changes in stats back to normal using the table in side.prevStats
    -- apply any transformation changes
    -- apply powerup changes
    -- check to see if anyone is dead
    -- change to new partner if someone is dead and a partner is available
    -- if not, give victory or defeat
    --
end