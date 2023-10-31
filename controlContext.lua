--This file contains the control schemes for button contexts.
local buttonBitMask = playdate.getButtonState()
function menuInputContext()
--[[
if playdate.buttonJustPressed("right") then
    local SptCn = playdate.graphics.sprite.getAllSprites()
    printTable(SptCn)
end
--]]
    if controlContext == GameMode.MENU  then
        if playdate.buttonJustPressed("b") then

        end
        if playdate.buttonJustPressed("a") then
            local fs = menuIndex[#menuIndex]
            goMenu(fs:getOption())
        end

        if playdate.buttonJustPressed("right") then
        end

        if playdate.buttonJustPressed("up") then
            local fs = menuIndex[#menuIndex]
            fs:menuControl("up")
        end

        if playdate.buttonJustPressed("down") then
            local fs = menuIndex[#menuIndex]
            fs:menuControl("down")
        end
    end

    if controlContext == GameMode.PAUSE  then
        if playdate.buttonJustPressed("b") then
            local fs = menuIndex[#menuIndex]
            buttonBitMask = playdate.getButtonState()
            fs:menuControl("b")
            if #menuIndex == 0 then
                controlContext = GameMode.MAP
            end
        end
        if playdate.buttonJustPressed("a") then
            local fs = menuIndex[#menuIndex]
            goMenu(fs:getOption())
        end

        if playdate.buttonJustPressed("right") then
        end

        if playdate.buttonJustPressed("up") then
            local fs = menuIndex[#menuIndex]
            fs:menuControl("up")
        end

        if playdate.buttonJustPressed("down") then
            local fs = menuIndex[#menuIndex]
            fs:menuControl("down")
        end
    end

    if controlContext == GameMode.BATTLE then

    end

   -- print("Checking control context:",controlContext)
   -- print("Checking gameMode:",gameMode)
    if controlContext == GameMode.MAP then
        
        if playdate.buttonJustPressed("b") then
            print("B button pressed in controlContext MAP mode")
            local bStat = playdate.getButtonState()
            if buttonBitMask ~= bStat then
                pauseMenu()
            end
        end
        if playdate.buttonJustPressed("a") then
            pMapSprite:handleInput("a")

        end
        if playdate.buttonIsPressed("right") then

            pMapSprite:handleInput("right")

        end

        if playdate.buttonIsPressed("up") then

            pMapSprite:handleInput("up")

        end

        if playdate.buttonIsPressed("down") then

            pMapSprite:handleInput("down")

        end

        if playdate.buttonIsPressed("left") then

            pMapSprite:handleInput("left")

        end
    end

    if controlContext == GameMode.STORY then
        if #menuIndex > 0 then
            if playdate.buttonJustPressed("a") then
                local fs = menuIndex[#menuIndex]
                
                fs:menuControl("a")
            end
        end

    end
end
function ctrlConSwi(item)
    if item ~= "off" then
        if item == "menu" then
            controlContext = GameMode.MENU
        elseif item == "story" then
            controlContext = GameMode.STORY
        elseif item == "map" then
            controlContext = GameMode.MAP
        elseif item == "battle" then
            controlContext = GameMode.BATTLE
        elseif item =="pause" then
            controlContext = GameMode.PAUSE
        else 
            print("Error in controlContext function: ctrlConSwi")
        end
    elseif item == "off" then
        controlContext = gameMode
    end
end