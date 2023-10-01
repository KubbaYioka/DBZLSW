--File Access Control
--Contains the functions for accessing save files


function clearOne() --checks to see if the game has been completed once
    local check = playdate.datastore.read("sav")

    local chkStor = check[2]
    for k, v in pairs(chkStor) do
        if k == "completed" then
            return v
        end
    end
end

function initLoadSav() --tests for save in game folder.
    if playdate.file.exists("sav.json") == false  then
        initSaveFile()
        currentPlayerData = playdate.datastore.read("sav")
        print("Save Created.")
        return false
    else
        currentPlayerData = playdate.datastore.read("sav")
        print("Save Loaded!")
        return true
    end
end

function gameContinue() -- returns the gamemode, story location, and key of story location
    local inthe = playdate.datastore.read("sav")
    local loc = inthe[2]
    local izu = loc.location
    local sub = loc.subloc
    local sum = "storyLoc"..izu
    if type(sub)=="number" then
        if sub == 1 then
            return "story", sum, sub 
        elseif sub==2 then
            modeChange("menu")
        elseif sub==3 then
            modeChange("map")
        end
    end
end

function initSaveFile() --creates the initial save file if none exists
    local chrDat ={}
    local storyDat = {}
    storyDat.location = 1
    storyDat.subloc = 1
    storyDat.completed = false
    for i=1, 300, 1 do
        chrDat[i] = "none" --create character slots for all potential characters. Indexes with value "none"
    end
    local gok = chrRet(dbGoku) --start with the default character. Kid Goku
    local kri = chrRet(dbKrillin) 
    chrDat[gok.roster] = gok --insert character into save file at prescribed index
    chrDat[kri.roster] = kri
    local savFil = {
        chrDat,
        storyDat
    }
    playdate.datastore.write(savFil, "sav", true)
end

--Function for pulling the saved players portion of the save file. All blank indexes ignored.
function loadSavedPlayers(mode, chr) -- Mode will change what kind of value is returned. full is full list. names is names only. ind requires a name to come after it. 
    local tblInc = playdate.datastore.read("sav")
    local tblMnf = tblInc[1]
    local tblJdf = {}
    for i, v in ipairs(tblMnf) do
        if type(v) == "table" then
            if mode=="names" then   --returns names of characters only
                tblJdf[i] = v.name
            elseif mode == "full" or "ind" then
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