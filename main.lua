--General Playdate Libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineSlice"

--Other Libraries
import "assets/secondlib/AnimatedSprite"

--Input Control
import 'controlContext'

--Menu Engine and General Game Logic
import 'menuEngine'
import 'gameModeEnum'

--Battle Engine
import 'battleEngine'
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

--Font
local dbFont = playdate.graphics.font.new('assets/fonts/DBLSW2')
playdate.graphics.setFont(dbFont) 

--Basic graphics setup
local gfx = playdate.graphics

--Initial Menu Settings

gridview = playdate.ui.gridview.new(0,20) -- initial gridview object 
gridview:setNumberOfColumns(1)
gridview:setNumberOfRows(1)
gridview:setCellPadding(0,0,4,0)
gridview:setContentInset(5,5,5,5)

--Set Menu\Text Border

gridview.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

--Master Tables

menuIndex = {}
portIndex = {}
tagIndex = {}

--Menu Object Classes

function gridview:new(gType,name) -- creates grid object based on parameters passed to it
-- types can be: dialogue, twoChoices, menu
    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    o.type = gType

    local menuX = 0 -- controls width of background box
    local menuY = 0 -- controls height of background box
    local xPos = 0
    local yPos = 0
    

    if o.type == "menu" or o.type == "twoChoices" then
        --options in menu list and menu orientation dependent on name variable
        -- so like if name == y then o.options = option table 1, etc
        o.options = {}
        o.options = name

        gridview:setNumberOfColumns(1)
        gridview:setNumberOfRows(#o.options)
        menuY = (#o.options * 25) + 10
        menuX = (100)
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

    elseif o.type == "dialogue" then
        menuY = (80)
        menuX = (400)
        o:setNumberOfRows(rows or 1)
        o:setNumberOfColumns(columns or 1)
        o.location = name
        o.key = 1
        o.cText = "none"

        function o:text()
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
                    gridviewSprite:setZIndex(1)
                elseif o.type == "twoChoices" then
                    gridviewSprite:moveTo(100, 100)
                end
            elseif o.type == "dialogue" then
                gridviewSprite:setZIndex(2)
                gridviewSprite:moveTo(0,160)
                gridview:setContentInset(5,20,0,0)
                gridview:setCellSize(380, 50)
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
                gfx.drawRect(x,y,width+2,height+2)
                gfx.drawRect(x,y,width,height)
            else
                gfx.drawRect(x,y,width,height)
            end
            menuText = o.options

        else-- for dialogue, etc
            menuText[1] = o.cText
        end

        local fontHeight = gfx.getSystemFont():getHeight()
        local rCount = row

        for i,v in pairs(menuText) do
            if rCount == i then
                gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.left)
            end
        end
    end

    function o:menuControl(direction) 
        if o.type == "menu" or o.type == "twoChoices" then
            if direction == "up" then
                o:selectPreviousRow(true)
            elseif direction == "down" then
                o:selectNextRow(true)
            end
        elseif o.type == "dialogue" then -- Iterates through all line items in a story.
            if direction == "a" then
                o:text()
                o:selectNextRow(true)
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
--END DEBUG BLOCK

gameBoot = 0
gameMode = GameMode.MENU 

function playdate.update()

   while gameBoot == 0 do -- First thing the game does is check for a save
        --show opening animation
        local ver = initLoadSav()
        if ver == false then -- if save is not found
            initSaveFile()
            gridview:new("menu", startMenu)
        elseif ver == true then
            local sit = clearOne() -- check to see if the game has been beaten once
            if sit == true then
                gridview:new("menu",fullMenuMain)
            elseif sit == false then
                gridview:new("menu",intermMenu)
            end
        end
        gameBoot = 1
    end

    menuInputContext()
    for i,v in pairs(menuIndex) do
        v:menuUpdate()
    end
    for i,v in pairs(portIndex) do
        v:portUpdate()
    end
    for i,v in pairs(tagIndex) do
        v:tagUpdate()
    end

    --UPDATE TIMERS
    playdate.timer.updateTimers()

    --UPDATE SPRITES
    gfx.sprite.update()

end