--General Playdate Libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineSlice"
import 'CoreLibs/ui/gridview.lua'

--Other Libraries
import "assets/secondlib/AnimatedSprite"

--Input Control
import 'controlContext'

--Menu Engine and General Game Logic
import 'menuEngine'
import 'gameModeEnum'

--Battle Engine
import 'battleEngine' --commented out. Something is crashing the program.
import '/data/battleData'

--Story Engine
import '/data/storyData'
import 'storyEngine'

--Map Engine 
import '/data/mapData'
import 'mapEngine'

--General Data
import '/genData/characters'
import '/genData/cards'
import '/genData/transformations'
import 'menuCat'
import '/genData/story'
import '/genData/maps'

--File Access
import 'fileAccess'

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

--Menu Object Class

--Initial Menu Settings

gridview = playdate.ui.gridview.new(0,20) -- initial gridview object 
gridview:setNumberOfColumns(1)
gridview:setNumberOfRows(1)
gridview:setCellPadding(0,0,4,0)
gridview:setContentInset(5,5,5,5)

--Set Menu\Text Border

gridview.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function gridview:new(gType,name) -- creates grid object based on parameters passed to it
-- types can be: dialogue, twoChoices, menu
    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    o.type = gType

    local menuX, menuY, xPos, yPos = 0,0,0,0 
    if o.type == "menu" or o.type == "twoChoices" then
        --options in menu list and menu orientation dependent on name variable
        -- so like if name == y then o.options = option table 1, etc
        o.options = {}
        o.options = name

        gridview:setNumberOfColumns(1)
        gridview:setNumberOfRows(#o.options)
        menuY = (#o.options * 25) + 10
        menuX = (130)
        xPos, yPos = menuPosition(name)
        --display menu
        
        function o:getOption() -- item selection in menu
            local s = o:getSelectedRow()
            for i,v in pairs(o.options) do
                if s==i then
                    return v
                end
            end
        end

    elseif o.type == "dialogue" or o.type == "mapDialogue" then
        menuY = (80)
        menuX = (400)
        o:setNumberOfRows(rows or 1)
        o:setNumberOfColumns(columns or 1)
        
        o.location = name
        o.key = 1
        o.cText = "none"

        function o:text()
            local qryText = nil
            local textRef = nil
            if o.type == "mapDialogue" then
                for i,v in pairs(o.location) do
                    for g, q in pairs(v) do
                        if g == "properties" then
                            local foundQryText = false
                            
                            for j, w in pairs(q) do
                                if j == "txtIter" then
                                    textRef = "text" .. w
                                end
                            end
                
                            for j, w in pairs(q) do
                                if j == textRef then
                                    qryText = w
                                    foundQryText = true
                                    break
                                end
                            end
                
                            if not foundQryText then
                                print("Error. Properties Not Found in Object.")
                                return
                            end
                        end
                    end
                end
                if #qryText >= o.key then
                    while type(qryText[o.key]) ~= "string" and o.key <= #qryText do
                        if type(qryText[o.key]) == "function" then
                            qryText[o.key]()
                        end
                        o.key = o.key + 1
                    end
                    if o.key <= #qryText then
                        o.cText = qryText[o.key]
                        o.key = o.key + 1
                    end
                end
                if o.key > #qryText then
                    o:spriteKill()
                    menuIndex = {}
                    ctrlConSwi("off")
                end
            
            elseif o.type == "dialogue" then
                for i,v in pairs(stories) do
                    if o.location == i then
                        while type(v[o.key]) ~= "string" do -- do something else with other triggers that might be for graphics or changes in scenery\characters
                            if type(v[o.key]) == "function" then
                                v[o.key]()
                            end
                            o.key = o.key + 1
                        end
                        o.cText = v[o.key]
                        o.key = o.key + 1
                    end
                end
            end
        end
    else
        print("Error in o.type")
    end

    local gridviewSprite = gfx.sprite.new()
    gridviewSprite:setCenter(0, 0)

    function o:spriteKill()
        gridviewSprite:remove()
    end

    gridviewSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local gridviewImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            if o.type == "menu" or o.type == "twoChoices" then
                if o.type == "menu" then
                    gridviewSprite:moveTo(xPos, yPos) -- same location as where the grid is drawn
                    gridviewSprite:setZIndex(130)
                elseif o.type == "twoChoices" then
                    gridviewSprite:moveTo(100, 100)
                    gridviewSprite:setZIndex(130)
                end
            elseif o.type == "dialogue" or o.type == "mapDialogue" then
                gridviewSprite:setZIndex(130)
                gridviewSprite:moveTo(0,160)
                o:setContentInset(5,20,10,0)
                o:setCellSize(380, 50)
            end
            gfx.pushContext(gridviewImage)
                o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            gridviewSprite:setImage(gridviewImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local menuText={}
        if o.type == "menu" then
            if selected then
                gfx.fillTriangle(x,y+5,x,y+20,x+10,y+12)
            end
            menuText = o.options

        else-- for dialogue, etc
            menuText[1] = o.cText
        end

        local fontHeight = gfx.getSystemFont():getHeight()

        for i,v in pairs(menuText) do
            if row == i then
                if o.type == "menu" then
                    nN = " "..v
                else 
                    nN = v
                end
                gfx.drawTextInRect(nN, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
            end
        end
    end

    function o:menuControl(direction) 
        if o.type == "menu" or o.type == "twoChoices" then
            if direction == "up" then
                o:selectPreviousRow(true,true,false)
            elseif direction == "down" then
                o:selectNextRow(true,true,false)
            end
        elseif o.type == "dialogue" or o.type == "mapDialogue" then -- Iterates through all line items in a story.
            if direction == "a" then
                
                o:text()
                o:selectNextRow(true,true,false)
            end
        end
    end

    local countI = 0
    for _ in pairs(menuIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    menuIndex[o.index] = o
    return o
end

--Background Image
local backgroundImage = gfx.image.new('assets/images/background/dragonBallTitle.png')
assert( backgroundImage )

gfx.sprite.setBackgroundDrawingCallback(
    function( x, y, width, height )
        -- x,y,width,height is the updated area in sprite-local coordinates
        -- The clip rect is already set to this area, so we don't need to set it ourselves
        backgroundImage:draw( 0, 0 )
    end)

function bgChange(bgImage)

    local backgroundImage = gfx.image.new('assets/images/background/'..bgImage..'.png')
    assert( backgroundImage )
    
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            -- x,y,width,height is the updated area in sprite-local coordinates
            -- The clip rect is already set to this area, so we don't need to set it ourselves
            backgroundImage:draw( 0, 0 )
        end)
end

--DEBUG BLOCK
function callRam()
    printTable(RAMSAVE)
end
--END DEBUG BLOCK

gameBoot = 0
gameMode = GameMode.MENU 
controlContext = GameMode.MENU

function playdate.update()
   while gameBoot == 0 do -- First thing the game does is check for a save
        --show opening animation
        ramSave()
        gameBoot = 1
    end

    menuInputContext()

    if #menuIndex > 0 then
        for i,v in pairs(menuIndex) do
            if i == #menuIndex then -- This ensures only the top-level menu has control context.
                v:menuUpdate()
            end
        end
    end

    if #dataBoxIndex > 0 then
        for i,v in pairs(dataBoxIndex) do
            v:menuUpdate()
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

    --UPDATE SPRITES
    gfx.sprite.update()
    --UPDATE TIMERS
    pd.timer.updateTimers()
end

