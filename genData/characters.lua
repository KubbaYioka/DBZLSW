--Character List
local gfx = playdate.graphics
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
        trans1 = "Base"
        ,trans2 = "Oozaru"
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

UnlockTables = { -- in format ["chrName"] = {flyunlock, limitunlock, focusunlock, powerupunlock} Specifies levels at which they unlock these things. 0 means never unlock.
    ["dbGoku"] = {10,4,3,10}
    ,["dbKrillin"] = {10,4,3,10}
    ,["dbBulma"] = {0,0,0,0}
    ,["dbYamcha"] = {10,4,3,10}
}

battleSpriteSheet = gfx.image.new('assets/images/battleSprites-table-16-16.png')

battleSprites = {
    ["dbGoku"] = {
        ["normal"] = 1
        ,["ready"] = 2
        ,["powerUp"] = 3
    }
    ,["dbKrillin"] = {        
        ["normal"] = 4
        ,["ready"] = 5
        ,["powerUp"] = 6
    },
    ["EOF"] = nil
}

function unlockCheck(chrCode,level)
    local reTable = {}
    for i,v in pairs(UnlockTables) do
        if i == chrCode then
            for k,j in pairs(v) do
                if level >= j then
                    reTable[k] = true
                else
                    reTable[k] = false
                end
            end
        end
    end
    return reTable -- reTable[1] is fly, 2 is limit, 3 is focus, 4 is powerup
end

function chrRet(chrCode) -- gets the character data from this location. Not for Save access.
    for i,v in pairs (characters) do
        if v.chrNum == chrCode then
            return v
        end
    end
end

function chrPort(chrStr,chrNum)
    for i,v in pairs (otherIndex) do
      if type(v) =="table" and v.chrIcon then
        v:spriteKill{}
      end
    end
    if chrStr ~= "  " then
      local chrtPort = ChrIcon(chrNum)
    end
  end

function chrGetLimit(chr,cIndex)
    local chrList = RAMSAVE[1]
    for i,v in pairs(chrList) do
        if type(v) == "table" then
            if v.chrNum == cIndex and v.chrName == chr then
                return v.limit
            end
        end
    end
end