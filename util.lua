local const = require("const")

local util = {}

util.dist = function(x1, y1, x2, y2)
    return ((x2-x1)^2+(y2-y1)^2)^0.5
end

util.calcTileRect = function(x, y)
    local xx = const.size.box * (x - 1) + const.size.border + const.size.edge
    local yy = const.size.box * (y - 1) + const.size.border + const.size.edge
    local ww = const.size.tile
    local hh = const.size.tile
    return xx, yy, ww, hh
end

util.buildLaserPath = function(tiles)
    local path = {}
    local idx = 1

    -- build first segment
    local t = tiles[idx]
    local xx, yy, ww, hh = util.calcTileRect(t[1], t[2])

    -- check for left or right laser
    if t[1] == 1 then
        -- start at the top of the tile
        table.insert(path, xx + (ww / 2))
        table.insert(path, yy - const.size.border)
    else
        -- start at the bottom of the tile
        table.insert(path, xx + (ww / 2))
        table.insert(path, yy + hh + const.size.border)
    end

    -- build remaining segments (center to center)
    while tiles[idx] ~= nil do
        local t = tiles[idx]
        local xx, yy, ww, hh = util.calcTileRect(t[1], t[2])
        table.insert(path, xx + (ww / 2))
        table.insert(path, yy + (hh / 2))

        idx = idx + 1
    end

    return path
end

return util
