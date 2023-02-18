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
    darkGray = {0.2, 0.2, 0.2},
    lightGray = {0.3, 0.3, 0.3},
    red = {0.6, 0.2, 0.2},
    silver = {0.7, 0.7, 0.7},
}

size = {
    tile = 64,
    border = 12,
}
size.box = size.tile + size.border

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


function drawTile(x, y)
    local poly = {
        -- top left
        size.box * (x - 1) + size.border, size.box * (y - 1) + size.border,
        -- top right
        size.box * (x - 1) + size.box, size.box * (y - 1) + size.border,
        -- bottom right
        size.box * (x - 1) + size.box, size.box * (y - 1) + size.box,
        -- bottom left
        size.box * (x - 1) + size.border, size.box * (y - 1) + size.box,
    }
    love.graphics.polygon("fill", poly)
end

function love.update(dt)

end

function love.draw(dt)
	local windowWidth, windowHeight = love.graphics.getDimensions()

    -- draw background / border
    love.graphics.setColor(color.darkGray)
    love.graphics.polygon("fill", 0, 0, windowWidth, 0, windowWidth, windowHeight, 0, windowWidth)

    -- draw tiles
    love.graphics.setColor(color.lightGray)
    for y = 1, board.height do
        for x = 1, board.width do
            drawTile(x, y)
        end
    end

    -- draw red tiles
    love.graphics.setColor(color.red)
    for _, p in ipairs(board.red) do
        drawTile(p[1], p[2])
    end

    -- draw silver tiles
    love.graphics.setColor(color.silver)
    for _, p in ipairs(board.silver) do
        drawTile(p[1], p[2])
    end

    -- draw pieces
    
    love.graphics.setColor(1,1,1)
	local mx, my = love.mouse.getPosition()
	love.graphics.line(windowWidth/2, windowHeight/2, mx, my)
end
