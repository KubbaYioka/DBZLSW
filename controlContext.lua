--This file contains the control schemes for button contexts.

local bounceProtect = false
SubMode = nil

SubEnum = {
    NONE = "none" --no inputs accepted
    ,MENU = "menu" --menu selections on battle screen
    ,STAT = "status" --specifically for status screen of cards and characters
    ,COMM = "command" -- for action commands
    ,MOVE = "move" -- for selecting a position on the movement grid
}

function getInput()
    if playdate.buttonJustPressed("b") then
        battleInputContext("b")
    elseif playdate.buttonJustPressed("a") then
        battleInputContext("a")
    elseif playdate.buttonJustPressed("right") then
        battleInputContext("right")
    elseif playdate.buttonJustPressed("up") then
        battleInputContext("up")
    elseif playdate.buttonJustPressed("down") then
        battleInputContext("down")
    elseif playdate.buttonJustPressed("left") then
        battleInputContext("left")
    end
end

function battleInputContext(dir) 
    if bounceProtect == false then

        if SubMode == SubEnum.NONE then

        elseif SubMode == SubEnum.MENU then
            if dir == "left" then
                local fs = menuIndex[#menuIndex]
                fs:selectPreviousColumn(true,true,false)
                for i,v in pairs(UIIndex) do
                    if v.tag == "UIInfo" and fs.tag ~= "optionSelect" then
                        v:selectPreviousRow(true,true,false)
                    end
                end
            elseif dir == "right" then
                local fs = menuIndex[#menuIndex]
                fs:selectNextColumn(true,true,false)
                for i,v in pairs(UIIndex) do
                    if v.tag == "UIInfo" and fs.tag ~= "optionSelect" then
                        v:selectNextRow(true,true,false)
                    end
                end
            elseif dir == "a" then
                local fs = menuIndex[#menuIndex]
                getNextBMenu(fs:getOption())
            elseif dir == "b" then
                if #menuIndex > 1 and menuIndex[#menuIndex].tag ~= "tossMenu" then
                    for i,v in pairs(menuIndex) do
                        if v.index == #menuIndex then
                            v:spriteKill()
                        end
                    end
                end
            end
        elseif SubMode == SubEnum.STAT then
            -- specifically for status screens of cards and characters
            if dir == "up" then
                -- display next character in team, if there.
                print("display next character in team, if there.")
            elseif dir == "down" then
                -- display previous character in team, if there.
                print("display previous character in team, if there.")
            elseif dir == "b" then
                for i,v in pairs(dataBoxIndex) do
                    v:menuControl("b")
                end
                SubMode = SubEnum.MENU
            end
        elseif SubMode == SubEnum.COMM then

        elseif SubMode == SubEnum.MOVE then
            local gt = UIIndex[#UIIndex]
            local fs = menuIndex[#menuIndex]
            if dir == "left" then
                fs:selectPreviousColumn(true,true,false)
                gt:selectPreviousRow(false,true,false)
            elseif dir == "right" then
                fs:selectNextColumn(true,true,false)
                gt:selectNextRow(false,true,false)
            elseif dir == "up" then
                fs:selectPreviousRow(true,true,false)
                gt:selectNextColumn(false,true,false)
            elseif dir == "down" then
                fs:selectNextRow(true,true,false)
                gt:selectPreviousColumn(false,true,false)
            elseif dir == "a" then
                movementConfirm(fs:getOption(),"player")
            elseif dir == "b" then
                for j,k in pairs(UIIndex) do
                    if k.index == #UIIndex and k.tag == "movementUIInfo" then
                        k:spriteKill()
                    end
                end
                for i,v in pairs(menuIndex) do
                    if v.index == #menuIndex and v.tag == "moveGrid" then
                        v:spriteKill()
                        SubMode = SubEnum.MENU
                    end
                end
            end
        elseif SubMode == SubEnum.DIAG then
            for i,v in pairs(menuIndex) do
                if v.tag == "batDialogue" then
                    local fs = menuIndex[#menuIndex]
                    if dir == "a" then
                        fs:menuControl("a")
                    end
                end
            end            
        end
    elseif bounceProtect == true then
        bounceProtectSwi("off")
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
                if fs.menuType == "menuSelect" or fs.menuType == "Status" or fs.menuType == "cardSelect" then
                    fs:menuControl("a")
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

   -- print("Checking control context:",controlContext)
   -- print("Checking gameMode:",gameMode)
    if controlContext == GameMode.MAP then
        
        if playdate.buttonJustPressed("b") then
            pauseMenu()
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
            bounceProtectSwi("on")
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