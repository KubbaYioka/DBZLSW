--This file contains the control schemes for button contexts.

function menuInputContext()
--[[
if playdate.buttonJustPressed("right") then
    local SptCn = playdate.graphics.sprite.getAllSprites()
    printTable(SptCn)
end
--]]

    if gameMode == "menu" then
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

    if gameMode == "battle" then

    end

    if gameMode == "map" then

    end

    if gameMode == "story" then
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
        local f = portIndex
        printTable(f)
    end


end