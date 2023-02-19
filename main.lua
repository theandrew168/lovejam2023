-- red
-- silver 

-- 10x8 board
-- some tiles colored (only those pieces can be there)

-- pharaoh (lose if this gets hit)
-- obelisk (basic blocker)
-- pyramid (single mirror, destroyed if hit from behind)
-- djed (double mirror, can't be destroyed)

-- 2 lasers (in TL / BR corners, facing up/down)
-- turn: move (8 way) OR rotate (90) + check laser
-- djed can swap places with pyramid or obelisk or either color

-- classic
-- imhotep
-- dynasty

color = {
    black = {0.0, 0.0, 0.0},
    laser = {0.7, 0.2, 0.2},
    darkGray = {0.2, 0.2, 0.2},
    lightGray = {0.3, 0.3, 0.3},
    red = {0.6, 0.2, 0.2},
    silver = {0.7, 0.7, 0.7},
}

size = {
    tile = 64,
    border = 12,
    edge = 48,
}
size.box = size.tile + size.border

button = {
    xoff = size.edge + size.border + size.tile / 2,
    yoff = size.edge / 2,
    radius = (size.edge / 2) - 8,
}

board = {
    width = 10,
    height = 8,
    red = {
        {1, 1},
        {1, 2},
        {1, 3},
        {1, 4},
        {1, 5},
        {1, 6},
        {1, 7},
        {1, 8},
        {1, 8},
        {9, 1},
        {9, 8},
    },
    silver = {
        {10, 1},
        {10, 2},
        {10, 3},
        {10, 4},
        {10, 5},
        {10, 6},
        {10, 7},
        {10, 8},
        {10, 8},
        {2, 1},
        {2, 8},
    },
}

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

down = false
function love.update(dt)
    local x, y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        if not down then
            local loc = pick(x, y)
            if loc then
                print(x, y, loc[1], loc[2], loc[3])
            end
        end
        down = true
    else
        down = false
    end
end

function love.draw(dt)
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
    -- TODO
    
    love.graphics.setColor(1,1,1)
    local mx, my = love.mouse.getPosition()
    love.graphics.line(windowWidth/2, windowHeight/2, mx, my)
end
