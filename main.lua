--General Playdate Libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineSlice"

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
spriteIndex = {}
tagIndex = {}

--Menu Object Class

function gridview:new(name, rows, columns, options, index, mType)
    local o = o or {}
    setmetatable(o, self)
    self.__index=self
    o.name = name or "none"
    o.mType = mType or nil

    o:setNumberOfRows(rows or 1)
    o:setNumberOfColumns(columns or 1)

    local gridviewSprite = gfx.sprite.new()
    gridviewSprite:setCenter(0, 0)

    if o.mType == "menu" then
        o.options = options or {}
        o.index = index or 1
    elseif o.mType == "story" then
        o.storyLoc = name
        o.key = options
        o.cText = "none"
        gridviewSprite:setZIndex(3)
    elseif o.mType == "tag" then
        gridviewSprite:setZIndex(5)
        gridviewSprite.tag = o.mType
        o.cText = name
        o.pos = options or "left" -- options argument passed as position
        o.index = "tag" -- object indexed in menuIndex as "tag", a unique key.
    end

    function o:spriteKill()
        gridviewSprite:remove()
    end

    gridviewSprite:add()
    
    function o:getOption()
        local s = o:getSelectedRow()
        for i,v in pairs(o.options) do
            if s==i then
                return v
            end
        end
    end

    function o:menuUpdate()
        if o.needsDisplay then
            local menuX = 0 -- controls width of background box
            local menuY = 0 -- controls height of background box
            if o.mType == "menu" then 
                menuY = (#options * 25) + 10
                menuX = (100)
            elseif o.mType == "story" then
                menuY = (80)
                menuX = (400)
            elseif o.mType == "tag" then
                menuY = (25)
                menuX = (100)
            end
            local gridviewImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            if o.mType == "menu" then
                gridviewSprite:moveTo(40, 40) -- same location as where the grid is drawn
            elseif o.mType == "story" then
                gridviewSprite:moveTo(0,160)
                gridview:setContentInset(5,10,0,0)
                gridview:setCellSize(380, 50)
            elseif o.mType == "tag" then
                gridview:setContentInset(0,0,0,0)
                gridview:setCellSize(100, 25)
                if o.pos == "left" then
                    gridviewSprite:moveTo(0,160)
                elseif o.pos == "right" then
                    gridviewSprite:moveTo(300,160)
                end
            end

            gfx.pushContext(gridviewImage)
            o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            gridviewSprite:setImage(gridviewImage)
        end
    end

    function o:text()
        if o.mType == "story" then
            for i,v in pairs(stories) do
                if o.storyLoc == i then
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

    function o:drawCell(section,row,column,selected,x,y,width,height)
        if o.mType == "menu" then
            if selected then
                gfx.drawRect(x,y,width+2,height+2)
                gfx.drawRect(x,y,width,height)
            else
                gfx.drawRect(x,y,width,height)
            end
        end
        local menuText={}

        if o.mType == "menu" then
            menuText = o.options
        else -- in "story" and "tag" instances
            menuText[1] = o.cText
        end

        local fontHeight = gfx.getSystemFont():getHeight()
        for i,v in pairs(menuText) do
            if row == i then
                if o.mType == "tag" then
                    gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
                else
                    gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.left)
                end
            end
        end
    end

    function o:menuControl(direction) 
        if o.mType == "menu" then
            if direction == "up" then
                o:selectPreviousRow(true)
            elseif direction == "down" then
                o:selectNextRow(true)
            end
        elseif o.mType == "story" then -- Iterates through all line items in a story.
            if direction == "a" then
                o:text()
                o:selectNextRow(true)
            end
        end
    end
    menuIndex[index] = o
    return o
end

--Background Image

local backgroundImage = gfx.image.new('assets/images/background/400240.png')
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
        local ver = initLoadSav()
        if ver == false then -- if save is not found
            initSaveFile()
            mMenu = gridview:new("Main Menu", 2, 1, startMenu, 1, "menu")
        elseif ver == true then
            local sit = clearOne() -- check to see if the game has been beaten once
            if sit == true then
                mMenu = gridview:new("Main Menu",4,1,fullMenuMain,1, "menu")
            elseif sit == false then
                mMenu = gridview:new("Main Menu", 3, 1, intermMenu, 1, "menu")
            end
        end
        gameBoot = 1
    end

    menuInputContext()
    for i,v in pairs(menuIndex) do
        v:menuUpdate()
    end
    
    for i,v in pairs(portIndex) do
        print("menuIndexNote")
        v:portUpdate()
    end

    --UPDATE TIMERS
    playdate.timer.updateTimers()

    --UPDATE SPRITES
    gfx.sprite.update()

end