--init.lua
--init values for animations such as tables and lists.

local gfx = playdate.graphics
local ui = playdate.ui

btlSprite = {}
btlSprite.__index = btlSprite

setmetatable(btlSprite, {
    __index = gfx.sprite
})

KiProjectile = {}
KiProjectile.__index = KiProjectile
setmetatable(KiProjectile, {
    __index = gfx.sprite
})

-- ki wave group

KiWave = {}
KiWave.__index = KiWave

KiBase = {}
KiBase.__index = KiBase
setmetatable(KiBase, {
    __index = gfx.sprite
})

KiEdge = {}
KiEdge.__index = KiEdge
setmetatable(KiEdge, {
    __index = gfx.sprite
})

KiTail = {}
KiTail.__index = KiTail
setmetatable(KiTail, {
    __index = gfx.sprite
})

KiWaveSeg = {}
KiWaveSeg.__index = KiWaveSeg
setmetatable(KiWaveSeg, {
    __index = gfx.sprite
})



Explosion = {}
Explosion.__index = Explosion
setmetatable(Explosion, {
    __index = gfx.sprite
})

BattleController = {}
BattleController.__index = BattleController

commandButtons = {}

animationInterrupts = {
    ["Stage Attacks"] = {"2 Stage Attack", "3 Stage Attack", "4 Stage Attack", "5 Stage Attack", "6 Stage Attack", "7 Stage Attack"},
    ["Defense"] = {"Endurance", "Deflect","Shockwave","Foresight","Instant Transmission","Time Freeze"},
    ["Beam"] = {},
    ["Physical"] = {},
    ["Support"] = {},
    ["Other"] = {},
    ["Transformation"] = {}
}

genericAnimationTable = { -- shared animation definitions for attacks with many users.
    "Cont. Kick",
    "Cont. Punch",
    "Ki Blast",
    "Ki Wave",
    "Kamehameha",
    "Sword Slash",
    "Pole Strike",
    "Pistol Shot",
    "Endurance",
    "Makoho",
    "Super Kamehameha",
    "stgPrepare",
    "Placeholder"

}

stageAtkCombos = { -- table of combinations associated with stage attacks. Selected at random.
    ["2 Stage Attack"] = {
        [1] = {"a","a"},
        [2] = {"back", "a"},
        [3] = {"a", "b"},
        [4] = {"b","up"},
        [5] = {"a", "down"},
        [6] = {"back", "b"},
        [7] = {"down", "a"},
        [8] = {"up", "b"},
        [9] = {"up","a"},
        [10] = {"b", "b"}
    },
    ["3 Stage Attack"] = {
        [1] = {"a","a", "b"},
        [2] = {"back", "a", "b"},
        [3] = {"a", "b", "back"},
        [4] = {"b","up","a"},
        [5] = {"a", "down","b"},
        [6] = {"back", "b", "a"},
        [7] = {"down", "a", "a"},
        [8] = {"up", "b", "down"},
        [9] = {"up","a", "back"},
        [10] = {"b", "b", "back"}
    },
    ["4 Stage Attack"] = {
        [1] = {"a","a", "b", "b"},
        [2] = {"back", "a", "b", "down"},
        [3] = {"a", "b", "back", "b"},
        [4] = {"b","up","a", "back"},
        [5] = {"a", "down","b", "a"},
        [6] = {"back", "b", "a", "a"},
        [7] = {"down", "a", "a", "b"},
        [8] = {"up", "b", "down", "b"},
        [9] = {"up","a", "back", "b"},
        [10] = {"b", "b", "back", "a"}
    },
    ["5 Stage Attack"] = {        
        [1] = {"a","a", "b", "b", "a"},
        [2] = {"back", "a", "b", "down","a" },
        [3] = {"a", "a", "a", "b", "back"},
        [4] = {"b","up","a", "back", "down"},
        [5] = {"a", "down","b", "a", "a"},
        [6] = {"back", "b", "a", "a", "back"},
        [7] = {"down", "a", "a", "b", "b"},
        [8] = {"up", "b", "down", "b", "up"},
        [9] = {"up","a", "back", "b", "down"},
        [10] = {"b", "b", "back", "a", "up"}
    },
    ["6 Stage Attack"] = {
        [1] = {"a","a", "b", "b", "a", "up"},
        [2] = {"back", "a", "b", "down","a", "back"},
        [3] = {"a", "a", "a", "b", "back", "b"},
        [4] = {"b","up","a", "back", "down", "a"},
        [5] = {"a", "down","b", "a", "a", "back"},
        [6] = {"back", "b", "a", "a", "back", "b"},
        [7] = {"down", "a", "a", "b", "b", "a"},
        [8] = {"up", "b", "down", "b", "up", "a"},
        [9] = {"up","a", "back", "b", "down", "a"},
        [10] = {"b", "b", "back", "a", "up", "b"}
    },
    ["7 Stage Attack"] = {
        [1] = {"a","up","b","down","back","a","b"},
        [2] = {"a","a","a","a","b","b","up"},
        [3] = {"up","b","a","b","down","a","b"},
        [4] = {"b","a","back","a","b","back","down"},
        [5] = {"up","a","back","b","down","a","back"},
        [6] = {"b","b","a","down","b","back","a"},
    },
}