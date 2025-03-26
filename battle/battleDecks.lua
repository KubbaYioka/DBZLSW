--battleDecks
--controls all card functions after initial setup of the decks in battleSetup

function drawCard()
    local enCardNum = #enemyDeck + 1
    local plCardNum = #playerDeck + 1
    enemyDeck[enCardNum], eDeckCopy = cardShuffle(eDeckCopy,false)
    playerDeck[plCardNum], pDeckCopy = cardShuffle(pDeckCopy,false)
end

function limitQuery(side) -- check to see if the player has limit deck unlocked and return deck if true
    if side == "player" then
        if playerChr.limit ~= nil and #playerChr.limit ~= 0 then
            return true
        else
            return false
        end
    elseif side == "enemy" then
        if enemyChr.limit ~= nil and #enemyChr.limit ~= 0 then
            return true
        else
            return false
        end
    end
end

function availabilityCheck(cardNumber,conditionTable) --checks for a card's availability at the given time and circumstance
    -- will need to revisit for attacks that require 2 chrs
    local phaseTable = conditionTable[1]
    local chrTable = conditionTable[2]
    local formTable = conditionTable[3]
    local ccTable = conditionTable[4]

    -- phase compatibility block
    if phaseTable[cardNumber] ~= CurrentPhase and phaseTable[cardNumber] ~= "both" then
        print("Card not available in current phase")
        return false
    end

    --chr compatibility block
    local chrFlag = false
    for i,v in pairs(chrTable) do
        if v == playerChr.chrCode then
            chrFlag = true
        end
    end
    if chrFlag == true then
        print("Card not compatible with current character")
        return false
    end

    --form compatibility block
    --[[
    for i,v in pairs(formTable) do
        if v == playerChr.trans then
            print("Transformations not yet implemented. Must be implemented in save file, battle init, and functions need to be made for determining available transformations based on level")
        end
    ]]
    
    --cc Amount Check
    for i,v in pairs(ccTable) do
        if ccTable[cardNumber] > playerCC then
            return false
        end
    end

    return true
end

function deckCheck() -- check to see how many cards are in the current hand
    if #playerDeck >= 6 then
        return true
    else
        return false
    end
end

function bShowCard(card) -- show the card info for the selected item (if it is a card)
    local retCard = cardRet(card)
    cardData(retCard)
    SubMode = SubEnum.STAT
end

function examineEffect(side,chrTab,card)
    chrTab = card.cAbility(side,chrTab,card.cPower)
    return chrTab
end

function battleCardConfirm(selOption,side) --confirm the selected option for the side who used it.
    --print("selOption for "..side.." is "..selOption)
    --print("Here is where selOption (a card name string) is compared with a table containing card names that can trigger the command input screen and can be expanded with other tables for other actions")
    if side == "enemy" then
        if #enemyDeck >= 6 then
            enemyDiscard()
        end
        -- Do enemy calcs for move
        enemyTurnTable = {}
        enemyTurnTable.card = cardRet(selOption)
        enemyTurnTable.mStats = turnStat(enemyChr,enemyTurnTable.card,"enemy")
        local cardRemove = enemyTurnTable.card
        for i,v in pairs(enemyDeck) do
            if cardRemove.cNumber == v then
                table.remove(enemyDeck,i)
            end
        end
    elseif side == "player" then
        --printTable(playerDeck)
        --print(selOption)

        playerTurnTable = {}
        playerTurnTable.card = cardRet(selOption)
        playerTurnTable.mStats = turnStat(playerChr,playerTurnTable.card,"player")
        local cardRemove = playerTurnTable.card
        if PlayerSelection == "jointDeck" then
            for i,v in pairs(playerDeck) do
                if cardRemove.cNumber == v then
                    table.remove(playerDeck,i)
                end
            end
        end
    end
end

function enemyDiscard()
    local discard = math.random(1,6)
    table.remove(enemyDeck,discard)
end