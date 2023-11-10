--File Access Control
--Contains the functions for accessing save files

--FILE ACCESS ENUMERATION
function saveCheck(location)
    local SAVCHECK = playdate.datastore.read("sav")
    if location == "chrs" then
        return SAVCHECK[1]
    elseif location == "cards" then
        return SAVCHECK[2]
    elseif location == "data" then 
        return SAVCHECK[3]
    elseif location == "all" then
        return SAVCHECK
    end
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

function initLoadSav() --tests for save in game folder.
    if playdate.file.exists("sav.json") == false  then
        initSaveFile()
        currentPlayerData = saveCheck("all")
        print("Save Created.")
        return false
    else
        currentPlayerData = saveCheck("all")
        print("Save Loaded!")
        return true
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
    storyDat.currentMode = GameMode.STORY
    storyDat.currentLocation = "storyLoc1"
    storyDat.completed = false
    for i=1, 150, 1 do -- 1500 card slots for now.
        cardDat[i] = 0 -- starts with zero for each kind of card.
    end

    for i=1,10,1 do -- create a nested table for comparison to all saved players
        local keyIterate = i
        local demoTabl = {}
        for g=1,5,1 do
            if i==1 and g==1 then
                local gok = chrRet("dbGoku")--start with the default character. Kid Goku
                demoTabl[g] = gok --insert character into save file at prescribed index
            else
                demoTabl[g] = "none"
            end
        end
        chrDat[i] = demoTabl
    end

    local savFil = {
        chrDat
        ,cardDat
        ,storyDat
    }
    playdate.datastore.write(savFil, "sav", true)
end

--Function for pulling the saved players portion of the save file. All blank indexes ignored.
function loadSavedPlayers(chr) -- Returns the character specified from the save file. 
    if chr == "all" then
        local tempTab = saveCheck("chrs")
        return tempTab
    else
        local tempTab = saveCheck("chrs")
        for i,v in pairs(tempTab) do
            for k,c in pairs(v) do
                print(k)
                print(c)
                if c.chrCode == chr then
                    print("chr found")
                    return c
                end
            end
        end
    end
end