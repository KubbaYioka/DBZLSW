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

function gameModeChange(mode, location, index)
    if mode == GameMode.BATTLE then
        --display vs and transition
    elseif mode == GameMode.MENU then
        -- gridview etc etc
        -- load appropriate menu
    elseif mode == GameMode.MAP then
        clearAll()
        gfx.clear()
        goMap(location) -- loads map from appropriate dataset
    elseif mode == GameMode.STORY then
        print("Mode is now Story.")
       -- gridview:new(name, rows, columns, options, index, mType)
        gridview:new(mode, location)
        -- load appropriate story
    end
    gameMode = mode
end

function clearMenus()
    for k,v in pairs(menuIndex) do
        menuIndex[k] = nil
    end
    menuIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearSprites()

    for k,v in pairs(spriteIndex) do
        spriteIndex[k] = nil
    end
    spriteIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearPorts()

    for k,v in pairs(portIndex) do
        portIndex[k] = nil
    end
    portIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearTags()

    for k,v in pairs(tagIndex) do
        tagIndex[k] = nil
    end
    tagIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearAll()
    clearTags()
    clearPorts()
    clearMenus()
    clearSprites()
end

function goMenu(item)       ------------change for new gamemode handler
    if item == "Continue" then
        clearMenus()
        local mode, loc = gameContinue()
        gameModeChange(mode, loc) 
    end
    if item == "New Game" then
        clearMenus()
    end
    if item == "Options" then
    end
    if item == "Battle" then
    end
end

function tablelength(T) --simple function to get length of table
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
  