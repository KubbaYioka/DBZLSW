--cleanup
--for wiping all animation-related things when the turn is over

local gfx = playdate.graphics
local ui = playdate.ui

function clearField() -- function that clears the battle graphics
    SubMode = SubEnum.NONE
    fadeInWhite("normal")
    clearBattleMenus()
    clearBattleFieldSprites()
    clearBottomUIInfo()
    clearStgElements()
    clearBattleSprites()
end

function clearExceptBattleSprites()
    SubMode = SubEnum.NONE
    fadeInWhite("normal")
    clearEffectTimers()
    clearBattleMenus()
    clearBattleFieldSprites()
    clearBottomUIInfo()
    clearStgElements()
end

function clearEffectTimers()
    for i,v in pairs(battleSpriteIndex) do
        for k,c in pairs(v.effectTimers) do
            c:remove()
        end
    end

end

function clearStgElements()
    for i,v in pairs(otherIndex) do
        if v.tag =="timerC" then
            v:spriteKill()
        end
    end
    for i,v in pairs(commandButtons) do
        v:spriteKill()
    end
end

function clearBattleSprites()
    for i,v in pairs (battleSpriteIndex) do
        v:spriteKill()
    end
    battleSpriteIndex["attacker"] = nil
    battleSpriteIndex["defender"] = nil
end

function clearBattleMenus()
    for i,v in pairs(menuIndex) do
        v:spriteKill()
    end
end

function clearBattleFieldSprites()
    for i,v in pairs(sprBIndex) do
        v:spriteKill()
    end
end

function clearBottomUIInfo()
    for i,v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            v:spriteKill()
        end
    end
end