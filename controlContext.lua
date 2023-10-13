--This file contains the control schemes for button contexts.

function menuInputContext()
--[[
if playdate.buttonJustPressed("right") then
    local SptCn = playdate.graphics.sprite.getAllSprites()
    printTable(SptCn)
end
--]]

    if gameMode == GameMode.MENU then
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

    if gameMode == GameMode.BATTLE then

    end

    if gameMode == GameMode.MAP then
        if playdate.buttonJustPressed("b") then

        end
        if playdate.buttonJustPressed("a") then
            pMapSprite:handleInput("a")
            print(pMapSprite.targetX,pMapSprite.x)
            print(pMapSprite.targetY,pMapSprite.y)

        end

        if playdate.buttonJustPressed("right") then
            pMapSprite:handleInput("right")
        end

        if playdate.buttonJustPressed("up") then
            pMapSprite:handleInput("up")
        end

        if playdate.buttonJustPressed("down") then
            pMapSprite:handleInput("down")
        end
        if playdate.buttonJustPressed("left") then
            pMapSprite:handleInput("left")
        end
    end

    if gameMode == GameMode.STORY then
        if #menuIndex > 0 then
            if playdate.buttonJustPressed("a") then
                local fs = menuIndex[#menuIndex]
                fs:menuControl("a")
            end
        end
        if playdate.buttonJustPressed("b") then
        end

    end

    if playdate.buttonJustPressed("b") then
        local fgd = playdate.graphics.sprite.getAllSprites()
        printTable(fgd)
    end

end