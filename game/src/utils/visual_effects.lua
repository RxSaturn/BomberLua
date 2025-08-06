local visual_effects = {
	particleSystems = {},
	animations = {},
	glowEffects = {},
	screenShake = {
		active = false,
		intensity = 0,
		duration = 0,
		timer = 0
	}
}

-- Cores com melhor saturação e harmonia
visual_effects.COLORS = {
	BACKGROUND = { 0.1, 0.6, 0.1 }, -- Verde mais vibrante para o fundo
	WALL_SOLID = { 0.3, 0.3, 0.4 }, -- Cinza azulado para paredes sólidas
	WALL_BRICK = { 0.8, 0.5, 0.3 }, -- Marrom quente para paredes destrutíveis
	BOMB = { 0.1, 0.1, 0.15 },     -- Quase preto para bombas
	BOMB_HIGHLIGHT = { 1, 0.6, 0 }, -- Laranja para o pavio
	EXPLOSION_CORE = { 1, 0.8, 0.2 }, -- Amarelo para o centro da explosão
	EXPLOSION_FLAME = { 1, 0.4, 0 }, -- Laranja para as chamas

	POWERUPS = {
		[1] = { 1, 0.3, 0.3 }, -- Vermelho mais vibrante para bombas
		[2] = { 1, 0.6, 0.1 }, -- Laranja mais vibrante para poder de fogo
		[3] = { 0.2, 0.7, 1 } -- Azul ciano para velocidade
	},

	PLAYERS = {
		{ 1,   0.2, 0.2, 1 }, -- Vermelho mais forte (Jogador 1)
		{ 0.2, 0.4, 1,   1 }, -- Azul médio (Jogador 2)
		{ 0.2, 0.9, 0.3, 1 }, -- Verde brilhante (Jogador 3)
		{ 1,   0.8, 0.2, 1 } -- Amarelo dourado (Jogador 4)
	}
}

-- Inicia o tremor de tela
function visual_effects.shakeScreen(intensity, duration)
	visual_effects.screenShake = {
		active = true,
		intensity = intensity or 5,
		duration = duration or 0.3,
		timer = duration or 0.3
	}
end

-- Atualiza o tremor de tela
function visual_effects.updateScreenShake(dt)
	if visual_effects.screenShake.active then
		visual_effects.screenShake.timer = visual_effects.screenShake.timer - dt
		if visual_effects.screenShake.timer <= 0 then
			visual_effects.screenShake.active = false
		end
	end
end

-- Aplica o tremor de tela
function visual_effects.applyScreenShake()
	if visual_effects.screenShake.active then
		local intensity = visual_effects.screenShake.intensity *
			(visual_effects.screenShake.timer / visual_effects.screenShake.duration)
		love.graphics.translate(
			love.math.random(-intensity, intensity),
			love.math.random(-intensity, intensity)
		)
	end
end

-- Desenha uma parede sólida mais detalhada
function visual_effects.drawSolidWall(x, y, size)
	-- Base da parede
	love.graphics.setColor(visual_effects.COLORS.WALL_SOLID)
	love.graphics.rectangle("fill", x, y, size, size)

	-- Destaque superior (mais claro)
	love.graphics.setColor(visual_effects.COLORS.WALL_SOLID[1] * 1.3,
		visual_effects.COLORS.WALL_SOLID[2] * 1.3,
		visual_effects.COLORS.WALL_SOLID[3] * 1.3)
	love.graphics.rectangle("fill", x, y, size, size / 10)
	love.graphics.rectangle("fill", x, y, size / 10, size)

	-- Sombra inferior (mais escura)
	love.graphics.setColor(visual_effects.COLORS.WALL_SOLID[1] * 0.7,
		visual_effects.COLORS.WALL_SOLID[2] * 0.7,
		visual_effects.COLORS.WALL_SOLID[3] * 0.7)
	love.graphics.rectangle("fill", x, y + size * 0.9, size, size / 10)
	love.graphics.rectangle("fill", x + size * 0.9, y, size / 10, size)

	-- Linhas de detalhe
	love.graphics.setColor(visual_effects.COLORS.WALL_SOLID[1] * 0.8,
		visual_effects.COLORS.WALL_SOLID[2] * 0.8,
		visual_effects.COLORS.WALL_SOLID[3] * 0.8)
	love.graphics.rectangle("fill", x + size * 0.33, y, 2, size)
	love.graphics.rectangle("fill", x + size * 0.66, y, 2, size)
	love.graphics.rectangle("fill", x, y + size * 0.33, size, 2)
	love.graphics.rectangle("fill", x, y + size * 0.66, size, 2)
end

-- Desenha uma parede destrutível mais detalhada
function visual_effects.drawBrickWall(x, y, size)
	-- Base da parede
	love.graphics.setColor(visual_effects.COLORS.WALL_BRICK)
	love.graphics.rectangle("fill", x, y, size, size)

	-- Padrão de tijolos
	love.graphics.setColor(visual_effects.COLORS.WALL_BRICK[1] * 0.8,
		visual_effects.COLORS.WALL_BRICK[2] * 0.8,
		visual_effects.COLORS.WALL_BRICK[3] * 0.8)

	-- Linhas horizontais (juntas de argamassa)
	local numLines = 4
	local lineHeight = 2
	local brickHeight = (size - lineHeight * (numLines - 1)) / numLines

	for i = 1, numLines - 1 do
		local yPos = y + i * (brickHeight + lineHeight) - lineHeight
		love.graphics.rectangle("fill", x, yPos, size, lineHeight)
	end

	-- Linhas verticais alternadas (juntas de argamassa)
	local offset = 0
	for i = 0, numLines - 1 do
		local yPos = y + i * (brickHeight + lineHeight)
		local numBricks = 2
		local brickWidth = size / numBricks

		for j = 1, numBricks - 1 do
			-- Alterna o padrão em cada linha
			local xPos = x + ((j + offset) % numBricks) * brickWidth - 1
			love.graphics.rectangle("fill", xPos, yPos, 2, brickHeight)
		end

		offset = (offset + 1) % 2
	end

	-- Destaque e sombra sutis para dar profundidade
	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle("fill", x, y, size, size / 10)
	love.graphics.setColor(0, 0, 0, 0.2)
	love.graphics.rectangle("fill", x, y + size * 0.9, size, size / 10)
end

-- Desenha uma bomba mais detalhada
function visual_effects.drawBomb(x, y, size, timer, isFlashing)
	local centerX = x + size / 2
	local centerY = y + size / 2
	local radius = size * 0.35

	-- Corpo da bomba
	love.graphics.setColor(visual_effects.COLORS.BOMB)
	love.graphics.circle("fill", centerX, centerY, radius)

	-- Brilho especular (reflexo de luz)
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.circle("fill", centerX - radius * 0.4, centerY - radius * 0.4, radius * 0.2)

	-- Pavio
	love.graphics.setColor(0.6, 0.3, 0.1)
	love.graphics.rectangle("fill", centerX - 2, centerY - radius - 10, 4, 10)

	-- Chama do pavio
	local flameHeight = 8 * (1 + math.sin(love.timer.getTime() * 10) * 0.2)
	love.graphics.setColor(1, 0.7, 0.2)
	love.graphics.polygon("fill",
		centerX, centerY - radius - 10 - flameHeight,
		centerX - 3, centerY - radius - 10,
		centerX + 3, centerY - radius - 10
	)

	-- Flash de aviso quando próximo de explodir
	if isFlashing and timer < 1 then
		if math.floor(timer * 10) % 2 == 0 then
			love.graphics.setColor(1, 0, 0, 0.5 * (1 - timer))
			love.graphics.circle("fill", centerX, centerY, radius * 1.3)
		end
	end
end

-- Desenha uma explosão mais detalhada
function visual_effects.drawExplosion(x, y, size, type, lifetime)
	local centerX = x + size / 2
	local centerY = y + size / 2

	-- Calcula a pulsação baseada no tempo de vida
	local pulse = math.sin(lifetime * 10) * 0.2 + 0.8

	-- Core da explosão
	love.graphics.setColor(visual_effects.COLORS.EXPLOSION_CORE[1],
		visual_effects.COLORS.EXPLOSION_CORE[2],
		visual_effects.COLORS.EXPLOSION_CORE[3],
		pulse)

	if type == "center" then
		-- Explosão central (circular)
		love.graphics.circle("fill", centerX, centerY, size * 0.4 * pulse)
	else
		-- Explosão em braço (oval)
		local width, height

		if type == "horizontal" then
			width = size * 0.8
			height = size * 0.5
		else -- vertical
			width = size * 0.5
			height = size * 0.8
		end

		love.graphics.ellipse("fill", centerX, centerY, width * pulse, height * pulse)
	end

	-- Chamas externas (mais alaranjadas)
	love.graphics.setColor(visual_effects.COLORS.EXPLOSION_FLAME[1],
		visual_effects.COLORS.EXPLOSION_FLAME[2],
		visual_effects.COLORS.EXPLOSION_FLAME[3],
		pulse * 0.8)

	-- Desenha pequenas partículas de fogo ao redor
	local numParticles = 6
	for i = 1, numParticles do
		local angle = (i / numParticles) * math.pi * 2 + love.timer.getTime() * 3
		local distance = size * 0.3 * pulse
		local particleX = centerX + math.cos(angle) * distance
		local particleY = centerY + math.sin(angle) * distance
		local particleSize = size * 0.15 * (0.8 + math.sin(angle * 3) * 0.2)

		love.graphics.circle("fill", particleX, particleY, particleSize)
	end

	-- Brilho central
	love.graphics.setColor(1, 1, 1, pulse * 0.5)
	love.graphics.circle("fill", centerX, centerY, size * 0.2 * pulse)
end

-- Desenha um power-up mais detalhado
function visual_effects.drawPowerup(x, y, size, type, pulse)
	local centerX = x + size / 2
	local centerY = y + size / 2
	local baseRadius = size * 0.35
	local radius = baseRadius * (1 + pulse * 0.2)

	-- Círculo externo (com brilho)
	love.graphics.setColor(visual_effects.COLORS.POWERUPS[type])
	love.graphics.circle("fill", centerX, centerY, radius)

	-- Borda brilhante
	love.graphics.setColor(1, 1, 1, 0.8)
	love.graphics.circle("line", centerX, centerY, radius)

	-- Brilho interno
	local innerGlow = 0.6 + pulse * 0.4
	love.graphics.setColor(1, 1, 1, 0.3 * innerGlow)
	love.graphics.circle("fill", centerX, centerY, radius * 0.7)

	-- Símbolos dos power-ups
	love.graphics.setColor(1, 1, 1)

	if type == 1 then -- Bomba Extra
		-- Símbolo de "+"
		local lineWidth = radius * 0.5
		love.graphics.setLineWidth(3)
		love.graphics.line(centerX - lineWidth / 2, centerY, centerX + lineWidth / 2, centerY)
		love.graphics.line(centerX, centerY - lineWidth / 2, centerX, centerY + lineWidth / 2)
		love.graphics.setLineWidth(1)
	elseif type == 2 then -- Fogo Extra
		-- Símbolo de fogo (triângulo)
		local flameSize = radius * 0.6
		love.graphics.polygon("fill",
			centerX, centerY - flameSize / 2,
			centerX + flameSize / 2, centerY + flameSize / 2,
			centerX - flameSize / 2, centerY + flameSize / 2
		)
	elseif type == 3 then -- Velocidade
		-- Símbolo de velocidade (seta)
		local arrowSize = radius * 0.6
		love.graphics.polygon("fill",
			centerX - arrowSize / 2, centerY - arrowSize / 2,
			centerX - arrowSize / 2, centerY + arrowSize / 2,
			centerX + arrowSize / 2, centerY
		)
	end

	-- Partículas brilhantes girando
	love.graphics.setColor(1, 1, 1, 0.7)
	local particleCount = 3
	for i = 1, particleCount do
		local angle = love.timer.getTime() * 2 + (i * math.pi * 2 / particleCount)
		local px = centerX + math.cos(angle) * radius * 0.8
		local py = centerY + math.sin(angle) * radius * 0.8
		love.graphics.circle("fill", px, py, 2)
	end
end

-- Desenha um jogador mais detalhado
function visual_effects.drawPlayer(x, y, size, id, direction, isMoving)
	local centerX = x + size / 2
	local centerY = y + size / 2
	local radius = size * 0.4

	-- Corpo do jogador
	love.graphics.setColor(visual_effects.COLORS.PLAYERS[id])

	-- Animação de "respiração" sutil
	local breathe = 1 + math.sin(love.timer.getTime() * 2) * 0.03
	love.graphics.circle("fill", centerX, centerY, radius * breathe)

	-- Borda mais escura
	love.graphics.setColor(visual_effects.COLORS.PLAYERS[id][1] * 0.7,
		visual_effects.COLORS.PLAYERS[id][2] * 0.7,
		visual_effects.COLORS.PLAYERS[id][3] * 0.7)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", centerX, centerY, radius * breathe)
	love.graphics.setLineWidth(1)

	-- Sombra embaixo do jogador
	love.graphics.setColor(0, 0, 0, 0.2)
	love.graphics.ellipse("fill", centerX, centerY + radius * 0.9, radius * 0.8, radius * 0.3)

	-- Olhos (duas bolinhas brancas)
	love.graphics.setColor(1, 1, 1)
	local eyeRadius = radius * 0.2
	local eyeDistance = radius * 0.4

	local leftEyeX, leftEyeY, rightEyeX, rightEyeY

	if direction == "up" then
		leftEyeX = centerX - eyeDistance / 2
		leftEyeY = centerY - eyeDistance / 2
		rightEyeX = centerX + eyeDistance / 2
		rightEyeY = centerY - eyeDistance / 2
	elseif direction == "down" then
		leftEyeX = centerX - eyeDistance / 2
		leftEyeY = centerY + eyeDistance / 2
		rightEyeX = centerX + eyeDistance / 2
		rightEyeY = centerY + eyeDistance / 2
	elseif direction == "left" then
		leftEyeX = centerX - eyeDistance / 2
		leftEyeY = centerY - eyeDistance / 2
		rightEyeX = centerX - eyeDistance / 2
		rightEyeY = centerY + eyeDistance / 2
	elseif direction == "right" then
		leftEyeX = centerX + eyeDistance / 2
		leftEyeY = centerY - eyeDistance / 2
		rightEyeX = centerX + eyeDistance / 2
		rightEyeY = centerY + eyeDistance / 2
	end

	love.graphics.circle("fill", leftEyeX, leftEyeY, eyeRadius)
	love.graphics.circle("fill", rightEyeX, rightEyeY, eyeRadius)

	-- Pupilas (pequenos círculos pretos)
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("fill", leftEyeX, leftEyeY, eyeRadius * 0.5)
	love.graphics.circle("fill", rightEyeX, rightEyeY, eyeRadius * 0.5)

	-- Animação de movimento
	if isMoving then
		local wobble = math.sin(love.timer.getTime() * 10) * size * 0.02
		love.graphics.setColor(1, 1, 1, 0.3)
		love.graphics.circle("fill", centerX, centerY + radius + wobble, radius * 0.2)
	end
end

-- Desenha o fundo do mapa com padrão
function visual_effects.drawBackground(width, height, tileSize)
	love.graphics.setColor(visual_effects.COLORS.BACKGROUND)
	love.graphics.rectangle("fill", 0, 0, width, height)

	-- Adiciona um sutil padrão de grade
	love.graphics.setColor(0, 0, 0, 0.05)

	for y = 0, math.ceil(height / tileSize) do
		love.graphics.line(0, y * tileSize, width, y * tileSize)
	end

	for x = 0, math.ceil(width / tileSize) do
		love.graphics.line(x * tileSize, 0, x * tileSize, height)
	end
end

return visual_effects
