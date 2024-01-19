--This file contains the control schemes for button contexts.

local bounceProtect = false

function getInput()
    if playdate.buttonJustPressed("b") then
        menuInputContext("b")
    elseif playdate.buttonJustPressed("a") then
        menuInputContext("a")
    elseif playdate.buttonJustPressed("right") then
        menuInputContext("right")
    elseif playdate.buttonJustPressed("up") then
        menuInputContext("up")
    elseif playdate.buttonJustPressed("down") then
        menuInputContext("down")
    elseif playdate.buttonJustPressed("left") then
        menuInputContext("left")
    end
end

function menuInputContext()

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
        if #dataBoxIndex > 0 then 
            if playdate.buttonJustPressed("b") then
                local fs = dataBoxIndex[1] -- the first index will always have o.conTag == true, so it will have menuControl.
                fs:menuControl("b")
            end
        else
            if playdate.buttonJustPressed("b") then      
                local fs = menuIndex[#menuIndex]
                fs:menuControl("b")
                if #menuIndex == 0 then -- if this is 0, then there are no more menus to be rendered and control should be relinquished to the previous game mode
                    bounceProtectSwi("on")
                    ctrlConSwi("off")
                end
            end
            if playdate.buttonJustPressed("a") then
                local fs = menuIndex[#menuIndex]
                if fs.menuType == "Status" then
                    chrData(fs:getSelectedRow(),"pause")
                else
                    goMenu(fs:getOption())
                end
            end

            if playdate.buttonJustPressed("left") then
                local fs = menuIndex[#menuIndex]
                fs:menuControl("left")
            end

            if playdate.buttonJustPressed("right") then
                local fs = menuIndex[#menuIndex]
                fs:menuControl("right")
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
    end

    if controlContext == GameMode.BATTLE then

    end

   -- print("Checking control context:",controlContext)
   -- print("Checking gameMode:",gameMode)
    if controlContext == GameMode.MAP then
        
        if playdate.buttonJustPressed("b") then
            if bounceProtect == false then
                pauseMenu()
            elseif bounceProtect == true then
                if playdate.buttonJustPressed("b") then
                    bounceProtectSwi("off")
                end
            end
        end
        if playdate.buttonJustPressed("a") then
            if bounceProtect == false then
                pMapSprite:handleInput("a")
            elseif bounceProtect == true then
                if playdate.buttonJustPressed("a") then
                    bounceProtect = false
                end
            end
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
            bounceProtectSwi("on")
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

function bounceProtectSwi(tog)
    if tog == "on" then
        bounceProtect = true
    elseif tog == "off" then
        bounceProtect = false
    end
end