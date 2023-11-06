--Character List
--Master list of initial values for all characters. Can be modified by save data or place in story.

--[[
desig = {"roster", "desig", "name", "hp", "str", "ki", "spd", "def", "exp", "levelcap", "appearance", "trans1", "trans1lvl",  
    "trans2", "trans2lvl", "trans3", "trans3lvl", "trans4", "trans4lvl", "trans5", "trans5lvl", "trans6", "trans6lvl", "trans7", 
    "trans7lvl", "trans8", "trans8lvl"}
    
    --]]

dbGoku = {01,"dbGoku","Goku",80,2,0,3,2,0,0,30,1,"Oozaru",0}
dbKrillin={02,"dbKrillin","Krillin",90,3,0,2,2,0,0,25,1}
dbBulma={03,"dbBulma","Bulma",25,1,1,1,1,1,0,15,1}
dbYamcha={04,"dbYamcha","Yamcha",80,2,1,2,2,0,0,25,1}

characters = {

["dbGoku"] = {
    chrNum = 01
    ,chrCode = "dbGoku"
    ,chrName = "Goku"
    ,chrHp = 80
    ,chrStr = 2
    ,chrKi = 0
    ,chrSpd = 3
    ,chrDef = 2
    ,chrExp = 0
    ,chrTrans = {
        trans1 = "Oozaru"
        }
    }
,["dbKrillin"] = {
    chrNum = 01
    ,chrCode = "dbKrillin"
    ,chrName = "Krillin"
    ,chrHp = 90
    ,chrStr = 3
    ,chrKi = 0
    ,chrSpd = 2
    ,chrDef = 2
    ,chrExp = 0
    ,chrTrans = {
        trans1 = "none"

        }
    }
,["dbBulma"] = {
    chrNum = 03
    ,chrCode = "dbBulma"
    ,chrName = "Bulma"
    ,chrHp = 10
    ,chrStr = 1
    ,chrKi = 0
    ,chrSpd = 1
    ,chrDef = 1
    ,chrExp = 0
    ,chrTrans = {
        trans1 = "none"

        }
    }
,["dbYamcha"] = {
    chrNum = 04
    ,chrCode = "dbYamcha"
    ,chrName = "Yamcha"
    ,chrHp = 100
    ,chrStr = 3
    ,chrKi = 1
    ,chrSpd = 4
    ,chrDef = 4
    ,chrExp = 0
    ,chrTrans = {
        trans1 = "none"

        }
    }
}

function chrRet(chrCode) -- gets the character data from this location. Not for Save access.
    for i,v in pairs (characters) do
        if v.chrCode == chrCode then
        return v
        end
    end
end

function chrList() -- function that scans the save file for a list of available characters and returns those that are there
    
end

-- Chr Portrait Enum

ChrPorts = {
    dbGoku = 1
    ,db = 2




}