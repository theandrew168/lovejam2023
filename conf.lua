function love.conf(t)
    local width = 10
    local height = 8
    local size = 64
    local border = 12

    local windowWidth = (size + border) * width + border
    local windowHeight = (size + border) * height + border

    t.title = "Khet"
    t.version = "11.4"
    t.window.width = windowWidth
    t.window.height = windowHeight
end
