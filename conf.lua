function love.conf(t)
    local width = 10
    local height = 8

    local size = 64
    local border = 12
    local box = size + border

    local edge = 48

    local windowWidth = (box * width) + border + (2 * edge)
    local windowHeight = (box * height) + border + (2 * edge)

    t.title = "Khet"
    t.version = "11.4"
    t.window.width = windowWidth
    t.window.height = windowHeight
end
