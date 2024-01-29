--Character List
--Master list of initial values for all characters. Can be modified by save data or place in story.

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




-- Chr Portrait Enum
ChrPorts = {
    dbGoku = 1
    ,db = 2
}