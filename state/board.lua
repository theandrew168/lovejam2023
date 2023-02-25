local const = require("const")
local global = require("global")
local util = require("util")

local Board = {}
Board.__index = Board

function pick(x, y)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    local redX, redY = const.button.xoff, const.button.yoff
    local redDist = util.dist(x, y, redX, redY)
    if redDist <= const.button.radius then
        return {"laser", "red"}
    end

    local silverX = windowWidth - const.button.xoff
    local silverY = windowHeight - const.button.yoff
    local silverDist = util.dist(x, y, silverX, silverY)
    if silverDist <= const.button.radius then
        return {"laser", "silver"}
    end

    for ty = 1, const.board.height do
        for tx = 1, const.board.width do
            local xx, yy, ww, hh = util.calcTileRect(tx, ty)
            if x >= xx and x <= xx + ww and y >= yy and y <= yy + hh then
                return {"tile", tx, ty}
            end
        end
    end

    return nil
end

function drawPiece(p)
    if p.color == "red" then
        love.graphics.setColor(const.color.red)
    else
        love.graphics.setColor(const.color.silver)
    end

    local xx, yy, ww, hh = util.calcTileRect(p.tile[1], p.tile[2])
    love.graphics.rectangle("fill", xx, yy, ww, hh)

    local t = const.size.tile

    -- rotation: 1, 2, 3, 4
    -- obelisk: all the same
    -- pharaoh: up, right, down, left
    -- pyramid: NE, SE, SW, NW (mirror direction)
    -- djed:    NE, SE, SW, NW (mirror direction)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(4)

    if p.kind == "obelisk" then
        -- no visible rotation
        love.graphics.rectangle("line", xx + (ww / 4), yy + (hh / 4), ww / 2, hh / 2)
    elseif p.kind == "djed" then
        -- two visible rotations
        if p.rotation == 1 or p.rotation == 3 then
            love.graphics.line(xx, yy, xx + ww, yy + hh)
        else
            love.graphics.line(xx, yy + hh, xx + ww, yy)
        end
    elseif p.kind == "pharaoh" then
        -- two visible rotations
        if p.rotation == 1 or p.rotation == 3 then
            love.graphics.line(xx, yy + (hh / 2), xx + ww, yy + (hh / 2))
            love.graphics.circle("line", xx + (ww / 2), yy + (hh / 2), ww / 4)
        else
            love.graphics.line(xx + (ww / 2), yy, xx + (ww / 2), yy + hh)
            love.graphics.circle("line", xx + (ww / 2), yy + (hh / 2), ww / 4)
        end
    elseif p.kind == "pyramid" then
        -- four visible rotations
        if p.rotation == 1 then
            love.graphics.line(xx, yy, xx + ww, yy + hh)
            love.graphics.line(xx, yy + hh, xx + (ww / 2), yy + (hh / 2))
        elseif p.rotation == 2 then
            love.graphics.line(xx, yy + hh, xx + ww, yy)
            love.graphics.line(xx, yy, xx + (ww / 2), yy + (hh / 2))
        elseif p.rotation == 3 then
            love.graphics.line(xx, yy, xx + ww, yy + hh)
            love.graphics.line(xx + (ww / 2), yy + (hh / 2), xx + ww, yy)
        elseif p.rotation == 4 then
            love.graphics.line(xx, yy + hh, xx + ww, yy)
            love.graphics.line(xx + (ww / 2), yy + (hh / 2), xx + ww, yy + hh)
        end
    end
end

function Board.new()
    local board = {}
    setmetatable(board, Board)

    board.laser = {
        active = false,
        time = nil,
        done = nil,
        path = nil
    }

    return board
end

local down = false
function Board:update(dt)
    local x, y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not down then
            local loc = pick(x, y)
            if loc then
                -- TODO: transition to "selection" or "laser"
                print(x, y, loc[1], loc[2], loc[3])

                local what = loc[1]
                if what == "laser" then
                    self.laser.active = true
                    self.laser.time = love.timer.getTime()
                    self.laser.done = self.laser.time + 2
                    self.laser.path = util.buildLaserPath({
                        {1,1},
                        {1,2},
                        {1,3},
                        {1,4},
                        {2,4},
                        {3,4},
                        {3,5},
                        {2,5},
                        {1,5},
                        {1,6},
                        {1,7},
                        {1,8},
                    })
                end
            end
        end
        down = true
    else
        down = false
    end

    if love.keyboard.isDown("escape") then
        return "pausemenu"
    end

    if self.laser.active then
        self.laser.time = self.laser.time + dt
        if self.laser.time > self.laser.done then
            self.laser.active = false
        end
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
            local xx, yy, ww, hh = util.calcTileRect(x, y)
            love.graphics.rectangle("fill", xx, yy, ww, hh)
        end
    end

    -- draw red tiles
    love.graphics.setColor(const.color.red)
    for _, p in ipairs(const.board.red) do
        local xx, yy, ww, hh = util.calcTileRect(p[1], p[2])
        love.graphics.rectangle("fill", xx, yy, ww, hh)
    end

    -- draw silver tiles
    love.graphics.setColor(const.color.silver)
    for _, p in ipairs(const.board.silver) do
        local xx, yy, ww, hh = util.calcTileRect(p[1], p[2])
        love.graphics.rectangle("fill", xx, yy, ww, hh)
    end

    -- draw pieces
    for _, p in ipairs(global.board) do
        drawPiece(p)
    end

    if self.laser.active then
        love.graphics.setColor(const.color.laser)
        love.graphics.setLineWidth(4)
        love.graphics.line(self.laser.path)
    end

    -- font test
    love.graphics.setColor(1,1,1)
    love.graphics.print("Hello Khet!", windowWidth / 2 - 48, 8)
end

return Board
