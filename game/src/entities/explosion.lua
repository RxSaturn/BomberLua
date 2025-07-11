local grid = require("src.utils.grid")

local explosion = {
    gridX = 0,      -- Posição X na grade
    gridY = 0,      -- Posição Y na grade
    timer = 0.5,    -- Tempo de duração da explosão (em segundos)
    type = "center" -- Tipo de explosão (centro, horizontal, vertical)
}

-- Cria uma nova explosão
function explosion:new(gridX, gridY, type)
    local newExplosion = {
        gridX = gridX,
        gridY = gridY, 
        timer = 0.5,
        type = type or "center"
    }
    
    setmetatable(newExplosion, self)
    self.__index = self
    return newExplosion
end

-- Atualiza o temporizador da explosão
function explosion:update(dt)
    self.timer = self.timer - dt
    return self.timer <= 0  -- Retorna true quando a explosão acabar
end

-- Desenha a explosão
function explosion:draw()
    local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)
    
    -- Cor da explosão
    love.graphics.setColor(1, 0.3, 0, 0.8)  -- Laranja avermelhado
    
    -- Desenha a explosão baseada no tipo
    love.graphics.rectangle("fill", pixelX + 4, pixelY + 4, grid.TILE_SIZE - 8, grid.TILE_SIZE - 8, 5, 5)
    
    -- Brilho central
    love.graphics.setColor(1, 0.8, 0, 0.5)  -- Amarelo
    love.graphics.rectangle("fill", pixelX + 16, pixelY + 16, grid.TILE_SIZE - 32, grid.TILE_SIZE - 32, 3, 3)
    
    -- Restaura a cor
    love.graphics.setColor(1, 1, 1)
end

return explosion
