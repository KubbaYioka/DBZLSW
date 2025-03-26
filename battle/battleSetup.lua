-- battleSetup
-- Initial variable setup for this particular instance of a battle. Base parameters, arena, etc.
-- Variables pulled from storage or built for "Random Battles"

local gfx = playdate.graphics

function battleInit(battleTable) -- copy values from tables and player save to create battle-only data
    bTabInit()
    if type(battleTable) ~= "table" then
        print("battle table is not in correct format")
    end
    BattleRef = battleTable
    local initPTeam = {"dbGoku"} -- will eventually pull from table RAMSAVE[5]
    local initChr = initPTeam[1] -- simply uses the first player in the team
    local oppTab = battleTable["oppoParam"]
    local initETeam = oppTab.oppoTeam
    local initEChr = initETeam[1]

    --CARD SETUP--

    --pDeckCopy = RAMSAVE[4]
    pDeckCopy = {1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10} -- will eventually pull from table RAMSAVE[4]
    playerDeck[1],playerDeck[2],playerDeck[3],pDeckCopy = cardShuffle(pDeckCopy,true)
    eDeckCopy = oppTab.opponentDeck -- pulls from where the enemy deck info is for this battle
    enemyDeck[1],enemyDeck[2],enemyDeck[3],eDeckCopy = cardShuffle(eDeckCopy,true)

    for i,v in pairs(initPTeam) do -- copy current players in team to battle ram
        local mTab = RAMSAVE[1]
        for j,k in pairs(mTab) do
            if type(k) == "table" then
                if k.chrCode == v then
                    playerTeam[i] = k
                    playerTeam[i].ability = unlockCheck(v,k.chrExp)
                    local lmtChk = playerTeam[i].ability
                    if lmtChk[2] == true then
                        playerTeam[i].limit = k.limit
                    end
                end
            end
        end
    end

    for i,v in pairs(initETeam) do
        for j,k in pairs(characters) do
            if v == j then
                enemyTeam[i] = characters[j]
                
                local chrLvlT = oppTab.opponentLvl
                enemyTeam[i].ability = unlockCheck(characters[j].chrCode,chrLvlT[i])
                local lmtChk = enemyTeam[i].ability
                if lmtChk[2] == true then
                    enemyTeam[i].limit = oppTab.opponentLimit[i]
                end

                enemyTeam[i].aiType = oppTab.opponentAIType[i]
                
                --Next, do calculations to set stats according to [oppoParam].opponentLvl and insert .opponentLimit, .hasFly, hasLimit, transformation etc
                enemyTeamRO = enemyTeam
            end
        end
    end
    playerChr = playerTeam[1]
    enemyChr = enemyTeam[1]
    currentAI = oppTab.opponentAIType[1]

    gameModeChange(GameMode.BATTLE)
    SubMode = SubEnum.NONE
    CurrentPhase = initTurn(playerChr,enemyChr)
    --Battle start screen
    battleIntro(playerChr.chrCode,#playerTeam,enemyChr.chrCode,#enemyTeam)
    battleSpriteSet(BattleRef)
    drawUI(CurrentPhase)
end

function cardShuffle(deck,initial)
    local cSelect = nil
    local cCount = 1
    local cOne, cTwo, cThree

    local tempTab = {cOne, cTwo, cThree}
    local emptyTest = 0 -- if this number reaches 20, then the deck is empty and no card is drawn.
    if initial == true then
        cCount = 3
    end
    for i=1,cCount,1 do
        cSelect = nil
        while cSelect == nil do
            cSelect = deck[math.random(1, #deck)] 
            if cSelect ~= nil then
                local spec = false
                for k,c in pairs(deck) do
                    if spec == false then
                        if c == cSelect then
                            deck[k]=nil -- card is no longer in the deck and is either discarded or in the hand
                            spec = true -- since cards are removed one at a time, this eliminates the first card found.
                        end
                    end
                end
                tempTab[i] = cSelect
            end
            emptyTest = emptyTest + 1
            if emptyTest >= #deck then
                return "No Cards Remaining"
            end
        end
    end
    
    if initial == true then
        return tempTab[1],tempTab[2],tempTab[3],deck
    else
        return tempTab[1],deck
    end
end