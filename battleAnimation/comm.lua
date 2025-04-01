--comm
--all functions related to COM inputs and handling.

local gfx = playdate.graphics
local ui = playdate.ui

function commandEnter() -- function for entering stage attack commands

    local result = cmdChl() -- returns a table with hits and\or misses and direction\button for each (eg, [1] = {"a",true}, [2] = {"up", false})
    local cmdAnim = getResultSequence(result) -- returns the animation sequence for the results

end

function getDefSeq(def)
    print("Command not yet defined. For defense command inputs")
end

function getDefAni(table)
    print("getDefAni is for returning animation tables similar to how setAniSeq")
end


function getStgSeq(stage) -- retrieves random sequence of COM inputs from the matrix in init.lua
    local seq = stageAtkCombos[stage]
    local randomIndex = math.random(#seq)
    return seq[randomIndex]
end

function setStgSeq(table, side)
    local chrA = getChar(side)
    local interTab = getStgPrepare() -- first three values should be the pre-cmd entry sequence. 
    local counter = #interTab + 1
    for i,v in pairs(stageAttackAni) do
        for j,k in pairs(table) do
            if i == k then
                interTab[counter] = v
                counter = counter + 1
            end
        end
    end
    local aniTable = {
        [chrA] = interTab
    }
    return aniTable
end

function getStgPrepare() --retrieves the animation for when characters prepare for a COM input
    for i,v in pairs (characterAnimationTables) do
        if i == "generic" then
            for k,c in pairs (v) do
                if k == "stgPrepare" then
                    return c
                end
            end
        end
    end
end

function getStageResults()
    return commandButtonResults
end

function setAttStep(interrupt) --checks to see if the interrupt is a stage attack.
    for i,v in pairs(animationInterrupts["Stage Attacks"]) do
        if interrupt == v then
            local nk = 10 --where nk is the number of potential stg atk combos in the table for that stg atk
            if v == "7 Stage Attack" then
                nk = 6 -- only 6 for 7 stg
            end
            local varIO = "stg"
            local selectedStg = {}
            local sInt = math.random(1,nk)
            for k,c in pairs(stageAtkCombos[interrupt]) do
                if sInt == k then
                    selectedStg = c
                end
            end
            --[[uncomment to use hardcoded combo
                    [1] = {"a","a"},
                    [2] = {"back", "a"},
                    [3] = {"a", "b"},
                    [4] = {"b","up"},
                    [5] = {"a", "down"},
                    [6] = {"back", "b"},
                    [7] = {"down", "a"},
                    [8] = {"up", "b"},
                    [9] = {"up","a"},
                    [10] = {"b", "b"}
            ]]--
            --selectedStg = stageAtkCombos[interrupt][5]
            --print("stage combo hard-coded in comm.lua for function setAttStep - line ~80")
            return {varIO, selectedStg}
        else
            print("Not a Stage Attack. Load normal animation cycle.")
        end
    end
end

function getPhysicalButton(button) -- helper function to turn "back" into something the PD can use.
    if button == "back" then
        return "right"
    else
        return button
    end
end

function checkStgCard(card) --checks to see the stage card selected in argument 'card'
    for i,v in pairs(animationInterrupts["Stage Attacks"]) do
        if card == v then
            return true
        end
    end
end

cmdButton = gfx.sprite:new()

function cmdButton:new(button, number, btlCont)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = cmdButton })
    self.contRef = btlCont

    self.button = button
    self.physicalButton = getPhysicalButton(button)
    self.number = number
    
    self.pressed = false
    self.wrong = false
    self.spriteTable = gfx.imagetable.new("assets/images/cmdIcons")

    self:setCenter(0,0)
    
    self.xPos = 50 + ((self.number * 32)+20)
    self.yPos = 205

    local col,row, col2, row2, col3, row3 = self:assignIcon(self.button)
    self:assignCoords(col,row,col2,row2,col3,row3)

    self:moveTo(self.xPos, self.yPos)
    self:setImage(self.icon)
    self:updateButton()
    
    self.tag = "btnPrompt"
    self:setZIndex(510)

    commandButtons[self.number] = self

    self:add()

    return self
end

function cmdButton:assignCoords(c1,r1,c2,r2,c3,r3)
    self.icon = self.spriteTable:getImage(c1,r1)
    self.iconCorrect = self.spriteTable:getImage(c2,r2)
    self.iconWrong = self.spriteTable:getImage(c3,r3)
end

function cmdButton:cmdInput(dir)
    local cont = self.contRef
    if dir == self.physicalButton then
        self.pressed = true
        self:setImage(self.iconCorrect)
        cont.commandButtonResults[self.number] = {true,1,self.physicalButton}
    elseif dir ~= self.physicalButton then
        self.pressed = true
        self.wrong = true
        self:setImage(self.iconWrong)
        cont.commandButtonResults[self.number] = {false,0,self.physicalButton}
    end
    return
end

function cmdButton:spriteKill()
    self:remove()
    for i, v in pairs(commandButtons) do
        if v == self then
            commandButtons[i] = nil
        end
    end
end

function cmdButton:updateButton()
    --self:setImage(self.icon)
end

function cmdButton:assignIcon(button)
    if button == "a" then
        return 1,1,1,2,1,3
    elseif button == "b" then
        return 2,1,2,2,2,3
    elseif button == "down" then
        return 3,1,3,2,3,3
    elseif button == "left" then
        return 4,1,4,2,4,3
    elseif button == "up" then
        return 5,1,5,2,5,3
    elseif button == "back" then
        return 6,1,6,2,6,3
    else
        print("Invalid Button in cmdButton:assignIcon")
        return nil
    end
end

saveButton = gfx.sprite:new() -- the little button that appears when a command is missed.

function saveButton:new(buttonTab)
    local self = gfx.sprite.new()
    setmetatable(self, { __index = saveButton })

    self.buttonTab = buttonTab
    self.blockButton = true
    
    self.pressed = false
    self.selected = "str"
    self.wrong = false
    self.spriteTable = gfx.imagetable.new("assets/images/cmdIcons")

    self:setCenter(0,0)

    self.upImage = self.spriteTable:getImage(7,1)
    self.downImage = self.spriteTable:getImage(8,1)
    self:moveTo(184, 50)
    self:setImage(self.upImage)
    
    self.tag = "savePrompt"
    self:setZIndex(510)
    commandButtons["savBtn"] = self
    self:add()
    return self
end

function saveButton:getResults()
    if self.pressed == true then
        if self.wrong == false then
            if self.selected == "a" then
                return "guard"
            elseif self.selected == "b" then
                return "continue"
            end
        elseif self.wrong == true then
            return "wrong"
        end
    elseif self.pressed == false then
        return "wrong"
    end
end

function saveButton:spriteKill()
    self:remove()
    commandButtons["savBtn"] = nil
end

stgCountdown = ui.gridview:new(20, 20) --object class for the countdown timer for entering commands
stgCountdown.__index = stgCountdown
stgCountdown:setNumberOfColumns(1)
stgCountdown:setCellPadding(0, 0, 0, 0)
stgCountdown:setContentInset(0, 0, 0, 0)

function stgCountdown:new(countDown)
    local self = setmetatable(ui.gridview.new(50,30), stgCountdown)
    self:init(countDown)
    return self
end

function stgCountdown:init(countDown)
    local sizeX, sizeY = 100, 15
    local xPos, yPos = 0, 190
    self.sizeX = sizeX
    self.sizeY = sizeY
    self.xPos = xPos
    self.yPos = yPos

    self.initialTime = 0
    self.active = true
    self.startTime = playdate.getCurrentTimeMilliseconds()
    
    -- Ensure displayTime is set correctly
    self.displayTime = countDown

    self:setNumberOfRows(1)
    self:setScrollDuration(0)
    
    self.countSprite = gfx.sprite.new()
    self.countSprite:setCenter(0, 0)
    self.countSprite:setZIndex(610)
    self.countSprite:moveTo(self.xPos, self.yPos)
    self.countSprite:add()

    self.tag = "timerC"

    self.index = #otherIndex + 1
    otherIndex[self.index] = self
end

function stgCountdown:spriteKill()
    self.countSprite:remove()
    for i, v in pairs(otherIndex) do
        if v.tag == "timerC" then
            otherIndex[i] = nil
        end
    end
end

function stgCountdown:timerUpdate()
    --if self.needsDisplay then
        local currentTime = playdate.getCurrentTimeMilliseconds()
        local elapsedTime = currentTime - self.startTime
        local stgImage = gfx.image.new(self.sizeX,self.sizeY,gfx.kColorBlack)
        self.countSprite:moveTo(self.xPos,self.yPos)
        self.initialTime = elapsedTime

        gfx.pushContext(stgImage)
            self:drawInRect(0,0,self.sizeX,self.sizeY)
        gfx.popContext()
        self.countSprite:setImage(stgImage)
        if self.initialTime >= self.displayTime then
            self.active = false
        end
    --end
end

function stgCountdown:drawCell(section, row, column, selected, x, y, width, height)
    gfx.fillRect(self.xPos, self.yPos, self.sizeX, self.sizeY)
    gfx.setFont(sysFNT.smDBFont)
    local fontHeight = gfx.getFont():getHeight()
    
    local dispTime = self.initialTime / 1000
    local fullTime = self.displayTime / 1000
    local text = string.format("%.2f / %.2f", dispTime, fullTime)
    local original_draw_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawTextInRect(text, x, y --[[+ (height / 2 - fontHeight / 2) + 2]], 80, height, nil, truncationString, kTextAlignment.center)
    gfx.setImageDrawMode(original_draw_mode)
end
