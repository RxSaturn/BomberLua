local grid = require("src.utils.grid")

local bomb = {
    gridX = 0,        -- Posição X na grade
    gridY = 0,        -- Posição Y na grade
    timer = 3,        -- Tempo até a explosão (em segundos)
    power = 1,        -- Alcance da explosão
    owner = 1,        -- ID do jogador que colocou a bomba
}

-- Inicializa uma nova bomba
function bomb:new(gridX, gridY, power, owner)
    local newBomb = {
        gridX = gridX,
        gridY = gridY, 
        timer = 3,
        power = power or 1,
        owner = owner or 1
    }
    
    setmetatable(newBomb, self)
    self.__index = self
    return newBomb
end

-- Atualiza o temporizador da bomba
function bomb:update(dt)
    self.timer = self.timer - dt
    return self.timer <= 0  -- Retorna true quando for hora de explodir
end

-- Desenha a bomba
function bomb:draw()
    local pixelX, pixelY = grid.toPixel(self.gridX, self.gridY)
    
    -- Define a cor da bomba (preto)
    love.graphics.setColor(0, 0, 0)
    
    -- Desenha o corpo da bomba
    local radius = grid.TILE_SIZE * 0.35
    love.graphics.circle("fill", pixelX + grid.TILE_SIZE/2, pixelY + grid.TILE_SIZE/2, radius)
    
    -- Desenha o pavio da bomba
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", 
        pixelX + grid.TILE_SIZE/2 - 2, 
        pixelY + grid.TILE_SIZE/2 - radius - 10, 
        4, 10)
        
    -- Pisca mais rápido conforme se aproxima da explosão
    if self.timer < 1 then
        if math.floor(self.timer * 10) % 2 == 0 then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.circle("fill", pixelX + grid.TILE_SIZE/2, pixelY + grid.TILE_SIZE/2, radius * 1.2)
        end
    end
    
    -- Restaura a cor
    love.graphics.setColor(1, 1, 1)
end

return bomb
