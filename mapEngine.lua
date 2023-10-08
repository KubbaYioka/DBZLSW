local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
---[[
--Example Map table 
mapNumberT = { --Test Map
tileSet = "assets/images/tilemaps/testTile-table-16-16"
,tWidth = 16
,tHeight = 16
}
--]]

--tilemap objects
mapLayout = gfx.tilemap.new()

function mapLayout:new(mapTable)
    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    --creates new tilemap and image table from a mapTable containing all information for each map
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    --clear all menus, portraits, text, etc
end