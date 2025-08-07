-- Requisita dependências
local grid = require("src.utils.grid")
local map_manager = require("src.managers.map_manager")
local bomb_manager = require("src.managers.bomb_manager")
local player_manager = require("src.managers.player_manager")
local powerup_manager = require("src.managers.powerup_manager")
local visual_effects = require("src.utils.visual_effects")

-- Inicialização do jogo
function love.load()
	-- Define a semente aleatória baseada no tempo
	math.randomseed(os.time())

	-- Inicializa os gerenciadores
	map_manager:init()
	bomb_manager:init()
	player_manager:init()
	powerup_manager:init(map_manager)
end

-- Lógica de atualização do jogo
function love.update(dt)
	-- Atualiza os jogadores
	player_manager:update(dt, map_manager, bomb_manager, powerup_manager)

	-- Atualiza as bombas e explosões
	bomb_manager:update(dt, map_manager, player_manager, powerup_manager)

	-- Verifica colisões com explosões explicitamente
	player_manager:checkExplosionHits(bomb_manager, powerup_manager, map_manager)

	-- Atualiza os power-ups
	powerup_manager:update(dt)

	-- Atualiza efeitos visuais
	if visual_effects and visual_effects.updateScreenShake then
		visual_effects.updateScreenShake(dt)
	end
end

-- Renderização do jogo
function love.draw()
	-- Aplica efeito de tremor de tela
	love.graphics.push()
	if visual_effects and visual_effects.applyScreenShake then
		visual_effects.applyScreenShake()
	end

	-- Desenha o mapa primeiro (fundo)
	map_manager:draw()

	-- Desenha as bombas e explosões
	bomb_manager:draw()

	-- Desenha os power-ups (meio)
	powerup_manager:draw()

	-- Desenha os jogadores (frente)
	player_manager:draw()

	-- Restaura a transformação (Efeitos de Tremor)
	love.graphics.pop()

	-- Desenha informações de depuração
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

	-- Mostra informações do jogador 1
	if #player_manager.players > 0 then
		local player = player_manager.players[1]
		if player.isAlive then
			love.graphics.print("Posição: " .. player.gridX .. ", " .. player.gridY, 10, 30)
			love.graphics.print("Bombas: " .. (player.maxBombs - player.currentBombs) .. "/" .. player.maxBombs, 10, 50)
			love.graphics.print("Poder: " .. player.bombPower, 10, 70)
			love.graphics.print("Velocidade: " .. player.speed, 10, 90)
		else
			love.graphics.print("Jogador Morto!", 10, 30)
		end
	end
end

-- Processa teclas pressionadas
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "r" then
		-- Reinicia o jogo
		map_manager:init()
		bomb_manager:init()
		player_manager:restart()
		powerup_manager:init(map_manager)
	else
		-- Passa as teclas para os jogadores
		player_manager:keypressed(key, map_manager, bomb_manager)
	end
end

-- Adiciona jogadores adicionais
function love.keyreleased(key)
	if key == "2" and #player_manager.players <= 2 then
		-- Adiciona Segundo jogador
		player_manager:addPlayer(2)
	elseif key == "3" and #player_manager.players < 3 then
		-- Adiciona Segundo e Terceiro jogadores
		player_manager:addPlayer(2)
		player_manager:addPlayer(3)
	elseif key == "4" and #player_manager.players < 4 then
		-- Adiciona Segundo, Terceiro e Quarto jogadores
		player_manager:addPlayer(2)
		player_manager:addPlayer(3)
		player_manager:addPlayer(4)
	end
end
