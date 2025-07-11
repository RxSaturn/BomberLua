local grid = require("src.utils.grid")

local player = {
    id = 1,             -- ID do jogador (1-4)
    gridX = 2,          -- Posição X atual na grade
    gridY = 2,          -- Posição Y atual na grade
    targetX = 2,        -- Posição X alvo na grade (para movimento suave)
    targetY = 2,        -- Posição Y alvo na grade (para movimento suave)
    pixelX = 64,        -- Posição X atual em pixels
    pixelY = 64,        -- Posição Y atual em pixels
    speed = 5,          -- Velocidade de movimento (células por segundo)
    isMoving = false,   -- Se o jogador está se movendo atualmente
    direction = "down", -- Direção atual que está olhando
    isAlive = true,     -- Se o jogador está vivo
    
    -- Atributos relacionados a bombas
    maxBombs = 1,       -- Número máximo de bombas que o jogador pode colocar
    currentBombs = 0,   -- Número de bombas atualmente colocadas
    bombPower = 1,      -- Alcance da explosão das bombas do jogador
    
    colors = {          -- Cores para cada jogador
        {1, 0, 0},      -- Vermelho (Jogador 1)
        {0, 0, 1},      -- Azul (Jogador 2)
        {0, 1, 0},      -- Verde (Jogador 3)
        {1, 1, 0}       -- Amarelo (Jogador 4)
    }
}

-- Cria um novo jogador
function player:new(id)
    local newPlayer = {
        id = id,
        gridX = 2,
        gridY = 2,
        targetX = 2,
        targetY = 2,
        pixelX = 64,
        pixelY = 64,
        speed = 5,
        isMoving = false,
        direction = "down",
        isAlive = true,
        maxBombs = 1,
        currentBombs = 0,
        bombPower = 1,
    }
    
    setmetatable(newPlayer, self)
    self.__index = self
    
    -- Inicializa o jogador
    newPlayer:init(id)
    
    return newPlayer
end

-- Inicializa o jogador
function player:init(id)
    self.id = id or 1
    self.isAlive = true
    self.maxBombs = 1
    self.currentBombs = 0
    self.bombPower = 1
    
    -- Define a posição inicial baseada no ID do jogador
    if self.id == 1 then
        -- Jogador 1: Topo-esquerda
        self.gridX = 2
        self.gridY = 2
    elseif self.id == 2 then
        -- Jogador 2: Topo-direita
        self.gridX = grid.WIDTH - 1
        self.gridY = 2
    elseif self.id == 3 then
        -- Jogador 3: Baixo-esquerda
        self.gridX = 2
        self.gridY = grid.HEIGHT - 1
    elseif self.id == 4 then
        -- Jogador 4: Baixo-direita
        self.gridX = grid.WIDTH - 1
        self.gridY = grid.HEIGHT - 1
    end
    
    self.targetX = self.gridX
    self.targetY = self.gridY
    self.pixelX, self.pixelY = grid.toPixel(self.gridX, self.gridY)
end

-- Mata o jogador
function player:kill()
    self.isAlive = false
end

-- Coloca uma bomba na posição atual
function player:placeBomb(map_manager, bomb_manager)
    if not self.isAlive then return false end
    
    -- Verifica se o jogador já atingiu o limite de bombas
    if self.currentBombs >= self.maxBombs then
        return false
    end
    
    -- Tenta colocar a bomba no mapa
    if bomb_manager:placeBomb(self.gridX, self.gridY, self.bombPower, self.id) then
        self.currentBombs = self.currentBombs + 1
        return true
    end
    
    return false
end

-- Atualiza a posição do jogador e processa entrada
function player:update(dt, map_manager, bomb_manager)
    if not self.isAlive then return end
    
    if self.isMoving then
        -- Continua o movimento em direção à posição alvo
        local targetPixelX, targetPixelY = grid.toPixel(self.targetX, self.targetY)
        local moveAmount = self.speed * grid.TILE_SIZE * dt
        
        local dx = targetPixelX - self.pixelX
        local dy = targetPixelY - self.pixelY
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < moveAmount then
            -- Chegamos ao destino
            self.pixelX = targetPixelX
            self.pixelY = targetPixelY
            self.gridX = self.targetX
            self.gridY = self.targetY
            self.isMoving = false
        else
            -- Move em direção ao alvo
            self.pixelX = self.pixelX + dx / distance * moveAmount
            self.pixelY = self.pixelY + dy / distance * moveAmount
        end
    else
        -- Processa entrada para novo movimento
        local newTargetX, newTargetY = self.gridX, self.gridY
        local keys = self:getPlayerKeys()
        
        if love.keyboard.isDown(keys.up) then
            newTargetY = self.gridY - 1
            self.direction = "up"
        elseif love.keyboard.isDown(keys.down) then
            newTargetY = self.gridY + 1
            self.direction = "down"
        elseif love.keyboard.isDown(keys.left) then
            newTargetX = self.gridX - 1
            self.direction = "left"
        elseif love.keyboard.isDown(keys.right) then
            newTargetX = self.gridX + 1
            self.direction = "right"
        end
        
        -- Verifica se podemos nos mover para a nova posição alvo
        if newTargetX ~= self.gridX or newTargetY ~= self.gridY then
            -- Verificamos se não há paredes
            if map_manager:isEmpty(newTargetX, newTargetY) then
                -- Verificamos se não há bombas
                if not bomb_manager:hasBomb(newTargetX, newTargetY) then
                    self.targetX = newTargetX
                    self.targetY = newTargetY
                    self.isMoving = true
                end
            end
        end
    end
end

-- Retorna as teclas específicas para este jogador
function player:getPlayerKeys()
    local keys = {}
    
    if self.id == 1 then
        -- Jogador 1: setas
        keys.up = "up"
        keys.down = "down"
        keys.left = "left"
        keys.right = "right"
        keys.bomb = "space"
    elseif self.id == 2 then
        -- Jogador 2: WASD
        keys.up = "w"
        keys.down = "s"
        keys.left = "a"
        keys.right = "d"
        keys.bomb = "lshift" -- Shift esquerdo
    elseif self.id == 3 then
        -- Jogador 3: IJKL
        keys.up = "i"
        keys.down = "k"
        keys.left = "j"
        keys.right = "l"
        keys.bomb = "rshift" -- Shift direito
    elseif self.id == 4 then
        -- Jogador 4: numpad
        keys.up = "kp8"
        keys.down = "kp5"
        keys.left = "kp4"
        keys.right = "kp6"
        keys.bomb = "kp0" -- 0 no numpad
    end
    
    return keys
end

-- Processa teclas pressionadas (para ações como colocar bombas)
function player:keypressed(key, map_manager, bomb_manager)
    if not self.isAlive then return end
    
    local keys = self:getPlayerKeys()
    
    -- Coloca bomba quando a tecla designada é pressionada
    if key == keys.bomb then
        return self:placeBomb(map_manager, bomb_manager)
    end
    
    return false
end

-- Desenha o jogador
function player:draw()
    if not self.isAlive then return end
    
    love.graphics.setColor(self.colors[self.id])
    
    -- Desenha o jogador como um círculo
    local radius = grid.TILE_SIZE * 0.4
    love.graphics.circle("fill", self.pixelX + grid.TILE_SIZE/2, self.pixelY + grid.TILE_SIZE/2, radius)
    
    -- Desenha o indicador de direção
    love.graphics.setColor(1, 1, 1)
    local indicatorX, indicatorY = self.pixelX + grid.TILE_SIZE/2, self.pixelY + grid.TILE_SIZE/2
    local indicatorSize = radius * 0.5
    
    if self.direction == "up" then
        love.graphics.circle("fill", indicatorX, indicatorY - indicatorSize, indicatorSize * 0.7)
    elseif self.direction == "down" then
        love.graphics.circle("fill", indicatorX, indicatorY + indicatorSize, indicatorSize * 0.7)
    elseif self.direction == "left" then
        love.graphics.circle("fill", indicatorX - indicatorSize, indicatorY, indicatorSize * 0.7)
    elseif self.direction == "right" then
        love.graphics.circle("fill", indicatorX + indicatorSize, indicatorY, indicatorSize * 0.7)
    end
    
    -- Restaura a cor
    love.graphics.setColor(1, 1, 1)
end

return player
