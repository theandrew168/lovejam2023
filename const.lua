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

local const = {
    color = {
        black = {0.0, 0.0, 0.0},
        laser = {0.8, 0.1, 0.1},
        darkGray = {0.2, 0.2, 0.2},
        lightGray = {0.3, 0.3, 0.3},
        red = {0.6, 0.2, 0.2},
        silver = {0.7, 0.7, 0.7},
    },

    size = {
        tile = 64,
        border = 12,
        edge = 48,
    },

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
    },

    -- rotation: 1, 2, 3, 4
    -- obelisk: all the same
    -- pharaoh: up, right, down, left
    -- pyramid: NE, SE, SW, NW (mirror direction)
    -- djed:    NE, SE, SW, NW (mirror direction)

    -- https://www.ultraboardgames.com/khet-the-laser-game/game-rules.php
    layout = {
        classic = {
            {tile = {5, 1},  kind = "obelisk", color = "red",    rotation = 1},
            {tile = {6, 1},  kind = "pharaoh", color = "red",    rotation = 3},
            {tile = {7, 1},  kind = "obelisk", color = "red",    rotation = 1},
            {tile = {8, 1},  kind = "pyramid", color = "red",    rotation = 2},
            {tile = {3, 2},  kind = "pyramid", color = "red",    rotation = 3},
            {tile = {4, 3},  kind = "pyramid", color = "silver", rotation = 4},
            {tile = {1, 4},  kind = "pyramid", color = "red",    rotation = 1},
            {tile = {3, 4},  kind = "pyramid", color = "silver", rotation = 3},
            {tile = {5, 4},  kind = "djed",    color = "red",    rotation = 1},
            {tile = {6, 4},  kind = "djed",    color = "red",    rotation = 2},
            {tile = {8, 4},  kind = "pyramid", color = "red",    rotation = 2},
            {tile = {10, 4}, kind = "pyramid", color = "silver", rotation = 4},
            {tile = {1, 5},  kind = "pyramid", color = "red",    rotation = 2},
            {tile = {3, 5},  kind = "pyramid", color = "silver", rotation = 4},
            {tile = {5, 5},  kind = "djed",    color = "silver", rotation = 2},
            {tile = {6, 5},  kind = "djed",    color = "silver", rotation = 1},
            {tile = {8, 5},  kind = "pyramid", color = "red",    rotation = 1},
            {tile = {10, 5}, kind = "pyramid", color = "silver", rotation = 3},
            {tile = {7, 6},  kind = "pyramid", color = "red",    rotation = 2},
            {tile = {8, 7},  kind = "pyramid", color = "silver", rotation = 1},
            {tile = {3, 8},  kind = "pyramid", color = "silver", rotation = 4},
            {tile = {4, 8},  kind = "obelisk", color = "silver", rotation = 1},
            {tile = {5, 8},  kind = "pharaoh", color = "silver", rotation = 1},
            {tile = {6, 8},  kind = "obelisk", color = "silver", rotation = 1},

            {tile = {10, 1},  kind = "obelisk", color = "silver", rotation = 1},
        },
    }
}

const.size.box = const.size.tile + const.size.border

const.button = {
    xoff = const.size.edge + const.size.border + const.size.tile / 2,
    yoff = const.size.edge / 2,
    radius = (const.size.edge / 2) - 8,
}

return const
