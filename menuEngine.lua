--Contains functions for menu rendering and modes

local gfx = playdate.graphics

function gridSprite(spriteType) -- sprite gen for menu\story
    local gridviewSprite = gfx.sprite.new()
    gridviewSprite:setCenter(0, 0)
    if spriteType == "menu" then
        gridviewSprite:moveTo(40, 40) -- same location as where the grid is drawn
    elseif spriteType == "story" then
        gridviewSprite:moveTo(0,180)
        gridview:setCellSize(240, 40)
    end
    gridviewSprite:add()
    return gridviewSprite
end

function gridviewRend()
    gridview = playdate.ui.gridview.new(0,20) -- initial gridview object 
    gridview:setNumberOfColumns(1)
    gridview:setNumberOfRows(1)
    gridview:setCellPadding(0,0,4,0)

    --Set Menu\Text Border 

    gridview.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)
    gridview:setContentInset(5,5,5,5)
    return gridview
end

function modeChange(string, storyLoc, index)
    if string == "battle" then
        --display vs and transition
    elseif string == "menu" then
        print("Mode Changed to Menu")
        if menuType == "menuBattle" then
            --load appropriate battle parameters. Recall stats and cards from save
        elseif menuType == "menuPause" then
            -- simply load the pause menu over the map screen
        elseif menuType == "title" then
            -- construct title menu
        end
        -- load appropriate menu
    elseif string == "map" then
        print("Mode Changed to Map")
        -- load appropriate map 
    elseif string == "story" then
        print("Mode Changed to Story")
        gameMode = "story"
       -- gridview:new(name, rows, columns, options, index, mType)
        local nDialogue = gridview:new(storyLoc,1,1,index,1, "story")
        -- load appropriate story from save
    end
end

function clearMenus()

    for k,v in pairs(menuIndex) do
        menuIndex[k] = nil
    end

    menuIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function goMenu(item)
    if item == "Continue" then
        clearMenus()
        local gmMode, storLoc, key = gameContinue()
        modeChange(gmMode, storLoc, key) 
    end
    if item == "New Game" then
        clearMenus()
        print("newGame()")
    end
    if item == "Options" then
    end
    if item == "Battle" then
    end
end