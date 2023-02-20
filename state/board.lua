local global = require("global")

local Board = {}
Board.__index = Board

function calcTilePoly(x, y)
    local poly = {
        -- top left
        size.box * (x - 1) + size.border + size.edge, size.box * (y - 1) + size.border + size.edge,
        -- top right
        size.box * (x - 1) + size.box + size.edge, size.box * (y - 1) + size.border + size.edge,
        -- bottom right
        size.box * (x - 1) + size.box + size.edge, size.box * (y - 1) + size.box + size.edge,
        -- bottom left
        size.box * (x - 1) + size.border + size.edge, size.box * (y - 1) + size.box + size.edge,
    }
    return poly
end

function dist(x1, y1, x2, y2)
    return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function pick(x, y)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    local redX, redY = button.xoff, button.yoff
    local redDist = dist(x, y, redX, redY)
    if redDist <= button.radius then
        return {"laser", "red"}
    end

    local silverX, silverY = windowWidth - button.xoff, windowHeight - button.yoff
    local silverDist = dist(x, y, silverX, silverY)
    if silverDist <= button.radius then
        return {"laser", "silver"}
    end

    for ty = 1, board.height do
        for tx = 1, board.width do
            local poly = calcTilePoly(tx, ty)
            local top, left = poly[2], poly[1]
            local bottom, right = poly[6], poly[5]
            if x >= left and x <= right and y >= top and y <= bottom then
                return {"tile", tx, ty}
            end
        end
    end

    return nil
end

function Board.new()
  local board = {}
  setmetatable(board, Board)

  return board
end

function Board:update(dt)
    local x, y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not down then
            local loc = pick(x, y)
            if loc then
                -- TODO: transition to "selection" or "laser"
                print(x, y, loc[1], loc[2], loc[3])
            end
        end
        down = true
    else
        down = false
    end
    if love.keyboard.isDown("escape") then
        return "pause"
    end
end

function Board:draw(dt)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- draw background
    love.graphics.clear(color.black)

    -- draw laser buttons
    love.graphics.setColor(color.laser)
    love.graphics.circle("fill",
        -- top left
        button.xoff,
        button.yoff,
        button.radius
    )
    love.graphics.circle("fill",
        -- bottom right
        windowWidth - button.xoff,
        windowHeight - button.yoff,
        button.radius
    )

    -- draw board background / border
    love.graphics.setColor(color.darkGray)
    love.graphics.polygon("fill",
        -- top left
        size.edge, size.edge,
        -- top right
        windowWidth - size.edge, size.edge,
        -- bottom right
        windowWidth - size.edge, windowHeight - size.edge,
        -- bottom left
        size.edge, windowHeight - size.edge
    )

    -- draw tiles
    love.graphics.setColor(color.lightGray)
    for y = 1, board.height do
        for x = 1, board.width do
            local poly = calcTilePoly(x, y)
            love.graphics.polygon("fill", poly)
        end
    end

    -- draw red tiles
    love.graphics.setColor(color.red)
    for _, p in ipairs(board.red) do
        local poly = calcTilePoly(p[1], p[2])
        love.graphics.polygon("fill", poly)
    end

    -- draw silver tiles
    love.graphics.setColor(color.silver)
    for _, p in ipairs(board.silver) do
        local poly = calcTilePoly(p[1], p[2])
        love.graphics.polygon("fill", poly)
    end

    -- draw pieces
    love.graphics.setColor(1,0,1)
    for _, p in ipairs(global.tiles) do
        local poly = calcTilePoly(p.tile[1], p.tile[2])
        love.graphics.polygon("fill", poly)
    end

    -- font test
    love.graphics.setColor(1,1,1)
    love.graphics.print("Hello Khet!", windowWidth / 2 - 48, 8)

    love.graphics.setColor(1,1,1)
    local mx, my = love.mouse.getPosition()
    love.graphics.line(windowWidth/2, windowHeight/2, mx, my)
end

return Board
