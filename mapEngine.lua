--Basic graphics setup

local gfx = playdate.graphics

local setMap = gfx.tilemap.new()

function setMap:new()
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    local loadedMap = maps.map
    printTable(loadedMap)

end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    --clear all menus, portraits, text, etc
    local mapRef = mapNumber
    printTable(mapRef)
    local tileset = setMap:new(mapRef[tileSet])
    local tileWidth = setMap:tileWidth(mapRef[tWidth])
    local tileHeight = setMap:tileHeight(mapRef[tHeight])

end

--Interactive Object Class

--

--