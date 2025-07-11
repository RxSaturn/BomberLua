local grid = require("src.utils.grid")

local map_manager = {
    tiles = {},  -- Armazenará os dados do mapa (layout)
}

-- Inicializa um novo mapa
function map_manager:init()
    -- Criar um mapa vazio
    for y = 1, grid.HEIGHT do
        self.tiles[y] = {}
        for x = 1, grid.WIDTH do
            -- Paredes da borda
            if x == 1 or x == grid.WIDTH or y == 1 or y == grid.HEIGHT then
                self.tiles[y][x] = 1  -- Parede indestrutível
            -- Padrão de paredes indestrutíveis (em cada posição ímpar)
            elseif x % 2 == 1 and y % 2 == 1 and x >= 3 and y >= 3 then
                self.tiles[y][x] = 1  -- Parede indestrutível
            else
                -- Posicionar paredes destrutíveis aleatoriamente (70% de chance)
                if math.random() < 0.7 then
                    self.tiles[y][x] = 2  -- Parede destrutível
                else
                    self.tiles[y][x] = 0  -- Espaço vazio
                end
            end
        end
    end
    
    -- Limpar áreas de spawn para os jogadores
    self:clearSpawnAreas()
end

-- Limpa as áreas de spawn dos jogadores
function map_manager:clearSpawnAreas()
    -- Jogador 1 (topo-esquerda)
    self.tiles[2][2] = 0  -- Posição do jogador
    self.tiles[2][3] = 0  -- Direita do jogador
    self.tiles[3][2] = 0  -- Abaixo do jogador
    
    -- Jogador 2 (topo-direita)
    self.tiles[2][grid.WIDTH-1] = 0  -- Posição do jogador
    self.tiles[2][grid.WIDTH-2] = 0  -- Esquerda do jogador
    self.tiles[3][grid.WIDTH-1] = 0  -- Abaixo do jogador
    
    -- Jogador 3 (baixo-esquerda)
    self.tiles[grid.HEIGHT-1][2] = 0  -- Posição do jogador
    self.tiles[grid.HEIGHT-1][3] = 0  -- Direita do jogador
    self.tiles[grid.HEIGHT-2][2] = 0  -- Acima do jogador
    
    -- Jogador 4 (baixo-direita)
    self.tiles[grid.HEIGHT-1][grid.WIDTH-1] = 0  -- Posição do jogador
    self.tiles[grid.HEIGHT-1][grid.WIDTH-2] = 0  -- Esquerda do jogador
    self.tiles[grid.HEIGHT-2][grid.WIDTH-1] = 0  -- Acima do jogador
end

-- Verifica se uma posição está ocupada por uma parede
function map_manager:isWall(gridX, gridY)
    -- Verifica se está fora dos limites
    if not grid.isWithinBounds(gridX, gridY) then
        return true
    end
    
    return self.tiles[gridY][gridX] > 0
end

-- Verifica se uma posição está vazia (sem paredes)
function map_manager:isEmpty(gridX, gridY)
    -- Verifica se está fora dos limites
    if not grid.isWithinBounds(gridX, gridY) then
        return false
    end
    
    return self.tiles[gridY][gridX] == 0
end

-- Destrói uma parede na posição especificada
function map_manager:destroyWall(gridX, gridY)
    -- Verifica se está dentro dos limites
    if not grid.isWithinBounds(gridX, gridY) then
        return false
    end
    
    -- Só pode destruir paredes destrutíveis
    if self.tiles[gridY][gridX] == 2 then
        self.tiles[gridY][gridX] = 0
        return true
    end
    
    return false
end

-- Desenha o mapa
function map_manager:draw()
    for y = 1, grid.HEIGHT do
        for x = 1, grid.WIDTH do
            local tileType = self.tiles[y][x]
            local pixelX, pixelY = grid.toPixel(x, y)
            
            -- Define a cor com base no tipo de tile
            if tileType == 1 then  -- Parede indestrutível
                love.graphics.setColor(0.5, 0.5, 0.5)  -- Cinza
            elseif tileType == 2 then  -- Parede destrutível
                love.graphics.setColor(0.8, 0.6, 0.4)  -- Marrom claro
            else  -- Espaço vazio
                love.graphics.setColor(0.2, 0.8, 0.2)  -- Verde
            end
            
            -- Desenha o tile
            love.graphics.rectangle("fill", pixelX, pixelY, grid.TILE_SIZE, grid.TILE_SIZE)
            
            -- Desenha a borda do tile
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("line", pixelX, pixelY, grid.TILE_SIZE, grid.TILE_SIZE)
        end
    end
    
    -- Restaura a cor
    love.graphics.setColor(1, 1, 1)
end

return map_manager
