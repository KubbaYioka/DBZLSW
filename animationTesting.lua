-- animation test environment

import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'genData/spriteMetadata'
import 'CoreLibs/timer'

local gfx = playdate.graphics
local ui = playdate.ui

local aniTestRoot = {"Select Character"}

function invokeAnimationTest()
    local rootAniTestMenu = regularBox:new(aniTestRoot)
    rootAniTestMenu.regSprite:moveTo(20,20)
    rootAniTestMenu.menuX = 120
    rootAniTestMenu.menuY = 120
end