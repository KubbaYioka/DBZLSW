--Character List
--Master list of initial values for all characters. Can be modified by save data or place in story.

--[[
desig = {"roster", "desig", "name", "hp", "str", "ki", "spd", "def", "spedef", "exp", "levelcap", "appearance", "trans1", "trans1lvl",  
    "trans2", "trans2lvl", "trans3", "trans3lvl", "trans4", "trans4lvl", "trans5", "trans5lvl", "trans6", "trans6lvl", "trans7", 
    "trans7lvl", "trans8", "trans8lvl"}
    
    --]]

dbGoku = {01,"dbGoku","Goku",80,2,0,3,2,0,0,30,1,"Oozaru",0}
dbKrillin={02,"dbKrillin","Krillin",90,3,0,2,2,0,0,25,1}
dbBulma={03,"dbBulma","Bulma",25,1,1,1,1,1,0,15,1}
dbYamcha={04,"dbYamcha","Yamcha",80,2,1,2,2,0,0,25,1}


function chrRet(chrName) -- gets the character data from this location. Not for Save access.
    local t = {}
    local u = {"roster","desig", "name", "hp", "str", "ki", "spd", "def", "spedef", "exp", "levelcap", "appearance", "trans1", "trans1lvl",  
    "trans2", "trans2lvl", "trans3", "trans3lvl", "trans4", "trans4lvl", "trans5", "trans5lvl", "trans6", "trans6lvl", "trans7", 
    "trans7lvl", "trans8", "trans8lvl"}
    for i, v in ipairs(u) do
        t[v]=chrName[i]
    end
    return t
end

function chrList() -- function that scans the save file for a list of available characters and returns those that are there
    
end