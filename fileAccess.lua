--File Access Control
--Contains the functions for accessing save files

--FILE ACCESS ENUMERATION
function saveCheck(location)
    if location == "chrs" then
        return RAMSAVE[1]
    elseif location == "cards" then
        return RAMSAVE[2]
    elseif location == "data" then 
        return RAMSAVE[3]
    elseif location == "deck" then
        return RAMSAVE[4]
    elseif location == "team" then
        return RAMSAVE[5] 
    elseif location == "mapInfo" then
        return RAMSAVE[6]
    elseif location == "all" then
        return RAMSAVE
    end
end

function ramSave() -- loads all save data into RAM. This is modified instead of the Save itself
    if playdate.file.exists("sav.json") == false then -- if save is not found
        initSaveFile()
        RAMSAVE = playdate.datastore.read("sav")
        titleMenu:new("menu", startMenu)
    elseif playdate.file.exists("sav.json") == true then
        RAMSAVE = playdate.datastore.read("sav")
        local sit = clearOne() -- check to see if the game has been beaten once
        if sit == true then
            titleMenu:new("menu",fullMenuMain)
        elseif sit == false then
            titleMenu:new("menu",intermMenu)
        end
    end
    
end

function saveGame()
    playdate.datastore.write(RAMSAVE, "sav", true)
end

function clearOne() --checks to see if the game has been completed once
    local check = saveCheck("data")
    for i,v in pairs(check) do
        if i == "completed" then
            printTable(v)
            return v
        end
    end
end

function gameContinue() -- returns the gamemode, story location
    local dataS = saveCheck("data")
    local gCMode = dataS.currentMode
    local location = dataS.currentLocation
    return gCMode, location
end

function initSaveFile() --creates the initial save file if none exists
    local chrDat = {}
    local storyDat = {}
    local cardDat = {}
    local teamDat = {} -- list of current fighters in a team
    local deckDat = {} -- list of current cards in the player's deck
    local mapInfo = {} -- used to track map state

    storyDat.currentMode = GameMode.STORY
    storyDat.currentLocation = "storyLoc1"
    storyDat.completed = false
    for i=1, 150, 1 do -- 150 card slots for now.
        cardDat[i] = 0 -- starts with zero for each kind of card.
    end

        local demoTabl = {}
        for g=1,50,1 do
            if g==1 then
                local gok = chrRet(1)--start with the default character. Kid Goku                
                gok.limit = {}
                demoTabl[g] = gok --insert character into save file at prescribed index
            else
                demoTabl[g] = "none"
            end
        end
        chrDat = demoTabl

        local deckTabl = {}
        for g=1,20,1 do
            deckTabl[g] = 0
        end
        deckDat = deckTabl
        
        teamDat = {0,0,0,0,0}

    local savFil = {
        chrDat
        ,cardDat
        ,storyDat
        ,deckDat
        ,teamDat
        ,mapInfo
    }
    playdate.datastore.write(savFil, "sav", true)
end

--Function for pulling the saved players portion of the save file. All blank indexes ignored.
function loadSavedPlayers(chr) -- Returns the character specified from the save file. 
    if chr == "all" then
        local tempTab = saveCheck("chrs")
        return tempTab
    elseif type(chr) == "number" then
        local tempTab = saveCheck("chrs")
        for i,v in pairs(tempTab) do
            if type(v) == "table" and v.chrNum == chr then
                return v
            end
        end
    end
end
function loadSavedCards(card) -- Returns the character specified from the save file. 
    local tempTab = nil
    if card == "all" then
        tempTab = saveCheck("cards")
    elseif card == "deck" then
        tempTab = saveCheck("deck")
    elseif card == "team" then
        tempTab = saveCheck("team")
    elseif card == "mapInfo" then
        tempTab = saveCheck("mapInfo")
    else
        local tempTab = saveCheck("cards")
        for i,v in pairs(tempTab) do
            for k,c in pairs(v) do
                if c.cName == card then
                    print("card found")
                    return c
                end
            end
        end
    end
    if tempTab ~= nil then
        return tempTab
    end
end

function saveIntCheck()
    print("function to check the integrity of the save file. The save file should have an expected configuration.")
end