local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics

class('PlayerMSprite').extends(AnimatedSprite)

function PlayerMSprite:init(image)
    local pTable = gfx.imagetable.new(image)
    PlayerMSprite.super.init(self, pTable)

    -- Define sprite states
    self:addState("down", 1, 2, {tickStep = 4})
    self:addState("up", 5, 6, {tickStep = 4})
    self:addState("left",7 ,8, {tickStep = 4})
    self:addState("right", 3, 4, {tickStep = 4})
    self:playAnimation()

    -- Properties
    self:changeState("down",true)
    self:moveTo(10, 10) -- will need to change
    self:setZIndex(100)
    --self:setCollideRect()
    self:add()
end

function PlayerMSprite:update()
    self:updateAnimation()
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        if button == "left" then
            self.currentState = PlayerMSprite.states.LEFT
        elseif button == "right" then
            self.currentState = PlayerMSprite.states.RIGHT
        elseif button == "up" then
            self.currentState = PlayerMSprite.states.UP
        elseif button == "down" then
            self.currentState = PlayerMSprite.states.DOWN
        end
    end
end


local currentMapImage = nil
currentMap = nil
currentPlrSprite = nil
function mapInit(map)
    currentMapImage = gfx.imagetable.new(map.tileSet)
    currentMap = gfx.tilemap.new()
    currentMap:setImageTable(currentMapImage)
    currentMap:setSize(map.mapWidth,map.mapHeight) --size in tiles.
    currentMap:setTiles(map.mLayout, map.mapWidth)
    local mapSprite = gfx.sprite.new()
    mapSprite:setTilemap(currentMap)
    mapSprite:moveTo(0,0)
    mapSprite:setCenter(0,0)
    mapSprite:setZIndex(1)
    mapSprite:add()

    --creates new tilemap and image table from a mapTable containing all information for each map
    
    currentPlrImage = map.mapChr
    print(currentPlrImage)
    local cX = map.chrX
    local cY = map.chrY
    PlayerMSprite(cX, cY, currentPlrImage)
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end
