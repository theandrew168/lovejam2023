local const = require("const")
local global = {}

local function dist(x1, y1, x2, y2)
    return ((x2-x1)^2+(y2-y1)^2)^0.5
end

local function calcTileRect(x, y)
    local xx = const.size.box * (x - 1) + const.size.border + const.size.edge
    local yy = const.size.box * (y - 1) + const.size.border + const.size.edge
    local ww = const.size.tile
    local hh = const.size.tile
    return xx, yy, ww, hh
end

local function buildLaserPath(board, player)
    local delta = {
        up = {0,-1},
        down = {0,1},
        left = {-1,0},
        right = {1,0},
    }

    -- determine initial tile and direction
    local cur = player == "red" and {1,1} or {10,8}
    local dir = player == "red" and "down" or "up"

    local path = {}
    table.insert(path, cur)

    while true do
        -- advance to the next tile (allow one tile of overflow)
        cur = {cur[1] + delta[dir][1], cur[2] + delta[dir][2]}
        table.insert(path, cur)

        -- check bounds
        if cur[1] < 1 or cur[1] > 10 or cur[2] < 1 or cur[2] > 8 then
            break
        end

        -- check if a piece is here
        local piece = nil
        for _, p in ipairs(board) do
            if p.tile[1] == cur[1] and p.tile[2] == cur[2] then
                piece = p
                break
            end
        end

        -- check if piece is hit or laser bounces
        if piece ~= nil then
            -- check for pieces that can't survive a hit
            if piece.kind == "pharaoh" or piece.kind == "obelisk" then
                break
            end

            if piece.kind == "pyramid" then
                if piece.rotation == 1 then
                    -- destroyed
                    if dir == "up" or dir == "right" then
                        break
                    end
                    -- reflected
                    dir = dir == "down" and "right" or "up"
                elseif piece.rotation == 2 then
                    -- destroyed
                    if dir == "down" or dir == "right" then
                        break
                    end
                    -- reflected
                    dir = dir == "up" and "right" or "down"
                elseif piece.rotation == 3 then
                    -- destroyed
                    if dir == "down" or dir == "left" then
                        break
                    end
                    -- reflected
                    dir = dir == "up" and "left" or "down"
                elseif piece.rotation == 4 then
                    -- destroyed
                    if dir == "up" or dir == "left" then
                        break
                    end
                    -- reflected
                    dir = dir == "down" and "left" or "up"
                end
            end

            if piece.kind == "djed" then
                -- djeds always reflect
                if piece.rotation == 1 or piece.rotation == 3 then
                    local reflect = {
                        up = "left",
                        down = "right",
                        left = "up",
                        right = "down",
                    }
                    dir = reflect[dir]
                elseif piece.rotation == 2 or piece.rotation == 4 then
                    local reflect = {
                        up = "right",
                        down = "left",
                        left = "down",
                        right = "up",
                    }
                    dir = reflect[dir]
                end
            end
        end
    end

    for _, p in ipairs(path) do
        print(unpack(p))
    end

    return path
end

local function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

local function buildLaserLine(tiles)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local minX, maxX = const.size.edge, windowWidth - const.size.edge
    local minY, maxY = const.size.edge, windowHeight - const.size.edge

    local line = {}
    local idx = 1

    -- build first segment
    local t = tiles[idx]
    local xx, yy, ww, hh = calcTileRect(t[1], t[2])

    -- check for left or right laser
    if t[1] == 1 then
        -- start at the top of the tile
        table.insert(line, xx + (ww / 2))
        table.insert(line, yy - const.size.border)
    else
        -- start at the bottom of the tile
        table.insert(line, xx + (ww / 2))
        table.insert(line, yy + hh + const.size.border)
    end

    -- build remaining segments (center to center)
    while tiles[idx] ~= nil do
        local t = tiles[idx]
        local xx, yy, ww, hh = calcTileRect(t[1], t[2])
        table.insert(line, clamp(xx + (ww / 2), minX, maxX))
        table.insert(line, clamp(yy + (hh / 2), minY, maxY))

        idx = idx + 1
    end

    return line
end

local function pick(x, y)
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

local function drawPiece(p)
    if p.color == "red" then
        love.graphics.setColor(const.color.red)
    else
        love.graphics.setColor(const.color.silver)
    end

    local xx, yy, ww, hh = calcTileRect(p.tile[1], p.tile[2])
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


function love.load(arg)
    -- load the funky egyptian font
    global.font = love.graphics.newFont("font/hieros.ttf", 36)
    love.graphics.setFont(global.font)

    -- load the music
    global.music = love.audio.newSource("music/khet.mp3", "stream")

    -- initialize the game state
    global.player = "silver"
    global.action = false
    global.laser = {
        active = false,
        time = nil,
        done = nil,
        path = nil,
        line = nil,
    }

    -- initialize the board with the classic layout
    global.board = {}
    local mode = const.layout.classic
    for _, p in ipairs(mode) do
        -- naive copy to keep game modes unmutated
        table.insert(global.board, {
            tile = {p.tile[1], p.tile[2]},
            kind = p.kind,
            color = p.color,
            rotation = p.rotation,
        })
    end
end

local down = false
function love.update(dt)
    -- keep background music playing indefinitely
    if not global.music:isPlaying() then
        love.audio.play(global.music)
    end

    local x, y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not down then
            local loc = pick(x, y)
            if loc then
                print(x, y, loc[1], loc[2], loc[3])

                local what = loc[1]
                if what == "laser" and loc[2] == global.player then
                    global.laser.active = true
                    global.laser.time = love.timer.getTime()
                    global.laser.done = global.laser.time + 2
                    global.laser.path = buildLaserPath(global.board, global.player)
                    global.laser.line = buildLaserLine(global.laser.path)
                end

                -- handle tile selection
                if what == "tile" then
                    -- find selected tile
                    local piece = nil
                    for _, p in ipairs(global.board) do
                        if p.tile[1] == loc[2] and p.tile[2] == loc[3] then
                            piece = p
                            break
                        end
                    end

                    -- update global with selected tile
                    if not global.selected and not global.action then
                        if piece and piece.color == global.player then
                            global.selected = piece
                            print("select", unpack(piece))
                        end
                    end

                    -- TODO: highlight adjacent tile w/o pieces

                    -- if one is clicked, move piece
                    if global.selected then
                        local d = dist(
                            global.selected.tile[1], global.selected.tile[2],
                            loc[2], loc[3]
                        )
                        if d > 0 and d < 2 then
                            print("move")
                            global.selected.tile = {loc[2], loc[3]}
                            global.selected = nil
                            global.action = true
                        end
                    end
                end
            end
        end
        down = true
    else
        down = false
    end

    -- handle piece rotation
    if love.keyboard.isDown("left") and global.selected then
        print("rotate")
        local rot = global.selected.rotation - 1
        global.selected.rotation = rot < 1 and 4 or rot
        global.selected = nil
        global.action = true
    elseif love.keyboard.isDown("right") and global.selected then
        print("rotate")
        local rot = global.selected.rotation + 1
        global.selected.rotation = rot > 4 and 1 or rot
        global.selected = nil
        global.action = true
    end

    -- handle quitting the game
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if global.laser.active then
        global.laser.time = global.laser.time + dt
        if global.laser.time > global.laser.done then
            global.laser.active = false

            -- remove any deleted piece
            local last = table.remove(global.laser.path)
            for i, p in ipairs(global.board) do
                if p.tile[1] == last[1] and p.tile[2] == last[2] then
                    table.remove(global.board, i)
                    break
                end
            end

            -- determine and declare game over
            local redHasPharaoh, silverHasPharaoh = false, false
            for _, p in ipairs(global.board) do
                if p.kind == "pharaoh" then
                    if p.color == "red" then
                        redHasPharaoh = true
                    else
                        silverHasPharaoh = true
                    end
                end
            end

            -- TODO: draw text, any key restarts?
            if not redHasPharaoh then
                print("Silver player wins!")
                love.event.quit()
            elseif not silverHasPharaoh then
                print("Red player wins!")
                love.event.quit()
            end

            -- switch player turn
            global.player = global.player == "red" and "silver" or "red"
            global.action = false
        end
    end
end

function love.draw(dt)
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
    for _, p in ipairs(global.board) do
        drawPiece(p)
    end

    -- draw laser
    if global.laser.active then
        love.graphics.setColor(const.color.laser)
        love.graphics.setLineWidth(4)
        love.graphics.line(global.laser.line)
    end

    -- print text (top)
    local text = "Welcome to Khet!"
    local w, h = global.font:getWidth(text), global.font:getHeight(text)
    love.graphics.setColor(1,1,1)
    love.graphics.print(text,
        (windowWidth / 2) - (w / 2),
        (const.size.edge - h) / 2
    )

    -- print current player (bottom)
    local text = "Player: " .. (global.player == "red" and "Red" or "Silver")
    local w, h = global.font:getWidth(text), global.font:getHeight(text)
    love.graphics.setColor(1,1,1)
    love.graphics.print(text,
        (windowWidth / 2) - (w / 2),
        windowHeight - const.size.edge
    )
end
