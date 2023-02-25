local const = require("const")
local global = require("global")

local Board = {}
Board.__index = Board

function calcTileRect(x, y)
    local xx = const.size.box * (x - 1) + const.size.border + const.size.edge
    local yy = const.size.box * (y - 1) + const.size.border + const.size.edge
    local ww = const.size.tile
    local hh = const.size.tile
    return xx, yy, ww, hh
end

function dist(x1, y1, x2, y2)
    return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function pick(x, y)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    local redX, redY = const.button.xoff, const.button.yoff
    local redDist = dist(x, y, redX, redY)
    if redDist <= const.button.radius then
        return {"laser", "red"}
    end

    local silverX = windowWidth - const.button.xoff
    local silverY = windowHeight - const.button.yoff
    local silverDist = dist(x, y, silverX, silverY)
    if silverDist <= const.button.radius then
        return {"laser", "silver"}
    end

    for ty = 1, const.board.height do
        for tx = 1, const.board.width do
            local xx, yy, ww, hh = calcTileRect(tx, ty)
            if x >= xx and x <= xx + ww and y >= yy and y <= yy + hh then
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
    love.graphics.clear(const.color.black)

    -- draw laser buttons
    love.graphics.setColor(const.color.laser)
    love.graphics.circle("fill",
        -- top left
        const.button.xoff,
        const.button.yoff,
        const.button.radius
    )
    love.graphics.circle("fill",
        -- bottom right
        windowWidth - const.button.xoff,
        windowHeight - const.button.yoff,
        const.button.radius
    )

    -- draw board background / border
    love.graphics.setColor(const.color.darkGray)
    love.graphics.rectangle("fill",
        const.size.edge,
        const.size.edge,
        windowWidth - (const.size.edge * 2),
        windowHeight - (const.size.edge * 2)
    )

    -- draw tiles
    love.graphics.setColor(const.color.lightGray)
    for y = 1, const.board.height do
        for x = 1, const.board.width do
            local xx, yy, ww, hh = calcTileRect(x, y)
            love.graphics.rectangle("fill", xx, yy, ww, hh)
        end
    end

    -- draw red tiles
    love.graphics.setColor(const.color.red)
    for _, p in ipairs(const.board.red) do
        local xx, yy, ww, hh = calcTileRect(p[1], p[2])
        love.graphics.rectangle("fill", xx, yy, ww, hh)
    end

    -- draw silver tiles
    love.graphics.setColor(const.color.silver)
    for _, p in ipairs(const.board.silver) do
        local xx, yy, ww, hh = calcTileRect(p[1], p[2])
        love.graphics.rectangle("fill", xx, yy, ww, hh)
    end

    -- draw pieces
    for _, p in ipairs(global.tiles) do
        if p.color == "red" then
            love.graphics.setColor(1,0,1)
        else
            love.graphics.setColor(1,0,1)
        end

        local xx, yy, ww, hh = calcTileRect(p.tile[1], p.tile[2])
        love.graphics.rectangle("fill", xx, yy, ww, hh)
    end

    -- font test
    love.graphics.setColor(1,1,1)
    love.graphics.print("Hello Khet!", windowWidth / 2 - 48, 8)

    love.graphics.setColor(1,1,1)
    local mx, my = love.mouse.getPosition()
    love.graphics.line(windowWidth/2, windowHeight/2, mx, my)
end

return Board
