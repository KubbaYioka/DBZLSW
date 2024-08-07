--General Playdate Libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineSlice"
import 'CoreLibs/ui/gridview.lua'
import 'CoreLibs/frameTimer'
import 'CoreLibs/timer'

--Other Libraries
import "assets/secondlib/AnimatedSprite"

--Input Control
import 'controlContext'

--Menu Engine and General Game Logic
import 'menuEngine'
import 'gameModeEnum'

--Battle Enginel9l
import 'battleEngine'

--Story Engine
import 'storyEngine'

--Map Engine 
import 'mapEngine'

--Battle Animations
import 'battleAnimations'

--General Data
import '/genData/characters'
import '/genData/cards'
import '/genData/transformations'
import 'menuCat'
import '/genData/story'
import '/genData/maps'
import '/genData/aiTypes'
import '/genData/battles'

--File Access
import 'fileAccess'

--Debug Functions
import 'debugF'
import 'animationTesting'

--Basic graphics setup
local gfx <const> = playdate.graphics
local pd <const> = playdate

sysFNT = {} -- table that stores all fonts.

--Font
sysFNT.dbFont = gfx.font.new('assets/fonts/DBLSW2')
sysFNT.smDBFont = gfx.font.new('assets/fonts/DBLSWSM')
gfx.setFont(sysFNT.dbFont)

--Master Tables

menuIndex = {} -- for all menu objects. Cleared between gamemodes.
portIndex = {} -- for keeping track of portraits in story mode.
tagIndex = {} -- for keeping track of dialogue tags
dataBoxIndex = {} -- for individually drawn data boxes like fields for card info
otherIndex = {} -- for misc objects that will not be used at the same time as any other misc object (e.g, menu icons)
mapObjIndex = {} -- for map objects
rectBoxIndex = {} -- table for the UI elements in the menu
battleSpriteIndex = {} -- table for battle sprites.

--Background Image

function bgChange(bgImage)
    local backgroundImage = gfx.image.new('assets/images/background/'..bgImage..'.png')
    gfx.sprite.setBackgroundDrawingCallback(function( x, y, width, height)backgroundImage:draw( 0, 0 )end)
end

bgChange("dragonBallTitle")

gameBoot = 0
gameMode = GameMode.MENU 
controlContext = GameMode.MENU

function playdate.update()
   while gameBoot == 0 do -- First thing the game does is check for a save
        --show opening animation
        ramSave()
        gameBoot = 1
    end

    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()

    menuInputContext()

    if #menuIndex > 0 then
        for i,v in pairs(menuIndex) do
            if i == #menuIndex then -- This ensures only the top-level menu has control context.
                v:menuUpdate()
            end
        end
    end

    if dataBoxIndex ~= nil then
        if #dataBoxIndex > 0 then
            for i,v in pairs(dataBoxIndex) do
                v:menuUpdate()
            end
        end
    end

    for i,v in pairs(portIndex) do
        v:portUpdate()
    end

    for i,v in pairs(tagIndex) do
        v:tagUpdate()
    end

    if gameMode == GameMode.MAP then
        if pMapSprite then
            if pMapSprite.hasContext then
                pMapSprite:updatePosition()
            end
        end
    end

    if gameMode == GameMode.BATTLE then
        getInput()
        for i,v in pairs(UIIndex) do
            v:menuUpdate()
        end
        for i,v in pairs(battleSpriteIndex) do
            v:drawBtl()
        end
    end
    
    --UPDATE SPRITES
    gfx.sprite.update()
    --UPDATE TIMERS
    pd.timer.updateTimers()
end