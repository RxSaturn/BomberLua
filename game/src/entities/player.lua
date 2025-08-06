local grid = require("src.utils.grid")
local input_system = require("src.systems.input_system")
local visual_effects = require("src.utils.visual_effects")

local player = {
	id = 1,          -- ID do jogador (1-4)
	gridX = 2,       -- Posição X atual na grade
	gridY = 2,       -- Posição Y atual na grade
	targetX = 2,     -- Posição X alvo na grade (para movimento suave)
	targetY = 2,     -- Posição Y alvo na grade (para movimento suave)
	pixelX = 64,     -- Posição X atual em pixels
	pixelY = 64,     -- Posição Y atual em pixels
	speed = 5,       -- Velocidade de movimento (células por segundo)
	isMoving = false, -- Se o jogador está se movendo atualmente
	direction = "down", -- Direção atual que está olhando
	isAlive = true,  -- Se o jogador está vivo

	-- Atributos relacionados a bombas
	maxBombs = 1,  -- Número máximo de bombas que o jogador pode colocar
	currentBombs = 0, -- Número de bombas atualmente colocadas
	bombPower = 1, -- Alcance da explosão das bombas do jogador

	colors = {     -- Cores para cada jogador
		{ 1, 0, 0 }, -- Vermelho (Jogador 1)
		{ 0, 0, 1 }, -- Azul (Jogador 2)
		{ 0, 1, 0 }, -- Verde (Jogador 3)
		{ 1, 1, 0 } -- Amarelo (Jogador 4)
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
		inputController = input_system.createController(),
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
	self.speed = 5 -- Velocidade base
	self.inputController = input_system.createController()

	-- Define a posição inicial baseada no ID do jogador
	self:setStartPosition()
end

-- Define a posição inicial do jogador
function player:setStartPosition()
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
	visual_effects.shakeScreen(8, 0.5) -- Tremor mais forte ao morrer
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

-- Processa inputs e movimento
function player:processMovement(dt, map_manager, bomb_manager)
	if self.isMoving then
		-- Continua o movimento em direção à posição alvo
		self:continueMovement(dt)

		-- Verifica curvas automáticas
		self:checkCornerTurn(map_manager, bomb_manager)
	else
		-- Tenta iniciar um novo movimento
		self:tryNewMovement(map_manager, bomb_manager)
	end
end

-- Continua o movimento atual
function player:continueMovement(dt)
	local targetPixelX, targetPixelY = grid.toPixel(self.targetX, self.targetY)
	local moveAmount = self.speed * grid.TILE_SIZE * dt

	local dx = targetPixelX - self.pixelX
	local dy = targetPixelY - self.pixelY
	local distance = math.sqrt(dx * dx + dy * dy)

	if distance < moveAmount then
		-- Chegamos ao destino - evite "passar do destino"
		self.pixelX = targetPixelX
		self.pixelY = targetPixelY
		self.gridX = self.targetX
		self.gridY = self.targetY
		self.isMoving = false

		-- Pequeno atraso antes de iniciar o próximo movimento
		self.inputController.cooldownActive = true
		self.inputController.cooldownTimer = 0.02 -- 20ms de espera
	else
		-- Move em direção ao alvo
		self.pixelX = self.pixelX + dx / distance * moveAmount
		self.pixelY = self.pixelY + dy / distance * moveAmount
	end
end

-- Verifica se pode fazer uma curva automática
function player:checkCornerTurn(map_manager, bomb_manager)
	if not self.isMoving then return end

	-- Determina direção atual
	local currentDirection = nil
	if self.targetX > self.gridX then
		currentDirection = "right"
	elseif self.targetX < self.gridX then
		currentDirection = "left"
	elseif self.targetY > self.gridY then
		currentDirection = "down"
	elseif self.targetY < self.gridY then
		currentDirection = "up"
	end

	-- Usa o input system para verificar curvas
	local cornerX, cornerY, cornerDir, progress = input_system.checkCornerTurn(
		self.inputController,
		self.gridX, self.gridY,
		self.targetX, self.targetY,
		self.pixelX, self.pixelY,
		currentDirection,
		map_manager, bomb_manager
	)

	if cornerX then
		-- Em vez de teleportar, ajustamos a posição atual proporcionalmente
		-- para simular uma curva suave
		local targetPixelX, targetPixelY = grid.toPixel(self.targetX, self.targetY)

		-- Avançamos para o centro da célula, mas não instantaneamente
		-- Quanto mais próximo do centro, mais suave a curva
		local centerFactor = math.min(1.0, progress * 1.5)
		self.pixelX = self.pixelX + (targetPixelX - self.pixelX) * centerFactor
		self.pixelY = self.pixelY + (targetPixelY - self.pixelY) * centerFactor

		-- Atualizamos a posição na grade
		self.gridX = self.targetX
		self.gridY = self.targetY

		-- Inicia o novo movimento (curva)
		self.targetX = cornerX
		self.targetY = cornerY
		self.direction = cornerDir
	end
end

-- Tenta iniciar um novo movimento
function player:tryNewMovement(map_manager, bomb_manager)
	local nextX, nextY, direction = input_system.getNextMove(
		self.inputController,
		self.gridX, self.gridY,
		map_manager, bomb_manager
	)

	if nextX then
		self.targetX = nextX
		self.targetY = nextY
		self.direction = direction
		self.isMoving = true
	end
end

-- Atualiza a posição do jogador e processa entrada
function player:update(dt, map_manager, bomb_manager)
	if not self.isAlive then return end

	-- Atualiza o buffer de input
	input_system.update(self.inputController, dt)

	-- Processa teclas pressionadas
	self:processInput(dt)

	-- Processa movimento
	self:processMovement(dt, map_manager, bomb_manager)
end

-- Processa inputs do teclado
function player:processInput(dt)
	local keys = self:getPlayerKeys()
	local anyKeyPressed = false

	-- Verificar se a função removeInput existe
	local removeInput = input_system.removeInput or function() end

	-- Verifica teclas de movimento
	if love.keyboard.isDown(keys.up) then
		input_system.bufferInput(self.inputController, "up", dt)
		anyKeyPressed = true
	else
		removeInput(self.inputController, "up")
	end

	if love.keyboard.isDown(keys.down) then
		input_system.bufferInput(self.inputController, "down", dt)
		anyKeyPressed = true
	else
		removeInput(self.inputController, "down")
	end

	if love.keyboard.isDown(keys.left) then
		input_system.bufferInput(self.inputController, "left", dt)
		anyKeyPressed = true
	else
		removeInput(self.inputController, "left")
	end

	if love.keyboard.isDown(keys.right) then
		input_system.bufferInput(self.inputController, "right", dt)
		anyKeyPressed = true
	else
		removeInput(self.inputController, "right")
	end

	-- Se nenhuma tecla estiver pressionada, limpa o buffer imediatamente
	if not anyKeyPressed and #self.inputController.inputQueue > 0 then
		self.inputController.inputQueue = {}
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

	local pixelX, pixelY = self.pixelX, self.pixelY
	visual_effects.drawPlayer(pixelX, pixelY, grid.TILE_SIZE, self.id, self.direction, self.isMoving)
end

return player
