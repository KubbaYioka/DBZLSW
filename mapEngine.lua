local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics

class('PlayerMSprite').extends(AnimatedSprite)

function PlayerMSprite:init(image)
    local pTable = gfx.imagetable.new(image)
    PlayerMSprite.super.init(self, pTable)

    -- Define sprite states
    self:addState("down",1,2,{tickStep = 12})
    self:addState("up",5,6,{tickStep = 12})
    self:addState("left",7,8,{tickStep = 12})
    self:addState("right",3,4,{tickStep = 12})
    self:playAnimation()

    -- Properties
    self:changeState("down",true)
    self:moveTo(100, 100) -- will need to change
    self:setZIndex(100)
    --self:setCollideRect()



printTable(self.states)

    self:add()
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        if button == "left" then
            self:changeState("left")

        elseif button == "right" then
            self:changeState("right")

        elseif button == "up" then
            self:changeState("up")

        elseif button == "down" then
            self:changeState("down")
        elseif button == "a" then
            print(PlayerMSprite.currentState)

        end
    end
end

function PlayerMSprite:update()
    self:updateAnimation()
end

local currentMapImage = nil
currentMap = nil
currentPlrSprite = nil
function mapInit(map)
    --creates new tilemap and image table from a mapTable containing all information for each map
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
    
    -- begin creating nes player sprite
    currentPlrImage = map.mapChr
    print(currentPlrImage)

    PlayerMSprite(currentPlrImage)
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end
