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
    printTable(check)
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
    local mode = dataS.currentMode
    local location = dataS.currentLocation
    return mode, location
end

function initSaveFile() --creates the initial save file if none exists
    local chrDat ={}
    local storyDat = {}
    local cardDat = {}
    storyDat.currentMode = GameMode.STORY
    storyDat.currentLocation = "storyLoc1"
    storyDat.completed = false
    for i=1, 500, 1 do -- 500 card slots for now.
        cardDat[i] = 0 -- starts with zero for each kind of card.
    end
    for i=1, 300, 1 do -- 300 is a placeholder for now.
        chrDat[i] = "none" --create character slots for all potential characters. Indexes with value "none"
    end
    local gok = chrRet("dbGoku") --start with the default character. Kid Goku
    chrDat[gok.chrNum] = gok --insert character into save file at prescribed index
    local savFil = {
        chrDat
        ,cardDat
        ,storyDat
    }
    playdate.datastore.write(savFil, "sav", true)
end

--Function for pulling the saved players portion of the save file. All blank indexes ignored.
function loadSavedPlayers(mode, chr) -- Mode will change what kind of value is returned. full is full list. names is names only. ind requires a name to come after it. 
    local tblInc = saveCheck("all")
    local tblMnf = tblInc[1]
    local tblJdf = {}
    for i, v in ipairs(tblMnf) do
        if type(v) == "table" then
            if mode=="names" then   --returns names of characters only
                tblJdf[i] = v.name
            elseif mode == "full" or mode == "ind" then
            tblJdf[i]=v
            end
        end
    end
    if mode == "ind" then            -- returns unformatted data on single character specified by chr
        for i,v in ipairs(tblJdf) do
            if v.desig == chr then
                return v
            end
        end
    end
    return tblJdf
end