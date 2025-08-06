local input_system = {
	bufferTimeout = 0.08, -- Tempo que um input permanece no buffer (em segundos)
	cornerThreshold = 0.5, -- Limiar para virar em cantos (0.0 a 1.0)
	inputCooldown = 0.05, -- Tempo mínimo entre novos movimentos
}

-- Cria um novo controlador de input para um jogador
function input_system.createController()
	return {
		inputBuffer = {}, -- Buffer para guardar inputs recentes
		inputQueue = {},  -- Fila de teclas atualmente pressionadas
		lastInputTime = 0, -- Último momento em que um input foi processado
		cooldownActive = false, -- Se está em cooldown após soltar teclas
		cooldownTimer = 0 -- Timer para o cooldown
	}
end

-- Adiciona um input ao buffer
function input_system.bufferInput(controller, input, dt)
	-- Adiciona o input com timestamp atual (se não estiver em cooldown)
	if not controller.cooldownActive then
		-- Verifica se já existe este input no buffer
		local found = false
		for _, entry in ipairs(controller.inputBuffer) do
			if entry.input == input then
				-- Atualiza o timer para o máximo
				entry.time = input_system.bufferTimeout
				found = true
				break
			end
		end

		-- Se não existir, adiciona ao buffer
		if not found then
			table.insert(controller.inputBuffer, {
				input = input,
				time = input_system.bufferTimeout
			})
		end

		-- Reseta o timer do último input
		controller.lastInputTime = 0
	end

	-- Adiciona à fila de teclas pressionadas (sempre, mesmo em cooldown)
	local found = false
	for _, v in ipairs(controller.inputQueue) do
		if v == input then
			found = true
			break
		end
	end

	if not found then
		table.insert(controller.inputQueue, 1, input) -- Adiciona ao início (mais recente)
	end
end

-- Remove um input da fila
function input_system.removeInput(controller, input)
	for i = #controller.inputQueue, 1, -1 do
		if controller.inputQueue[i] == input then
			table.remove(controller.inputQueue, i)
			break
		end
	end
end

-- Atualiza o buffer de input
function input_system.update(controller, dt)
	-- Atualiza o tempo desde o último input
	controller.lastInputTime = controller.lastInputTime + dt

	-- Atualiza cooldown se ativo
	if controller.cooldownActive then
		controller.cooldownTimer = controller.cooldownTimer - dt
		if controller.cooldownTimer <= 0 then
			controller.cooldownActive = false
		end
	end

	-- Atualiza o buffer de inputs
	for i = #controller.inputBuffer, 1, -1 do
		controller.inputBuffer[i].time = controller.inputBuffer[i].time - dt
		if controller.inputBuffer[i].time <= 0 then
			table.remove(controller.inputBuffer, i)
		end
	end

	-- Se não houver teclas pressionadas, limpa o buffer completamente
	if #controller.inputQueue == 0 and #controller.inputBuffer > 0 then
		controller.inputBuffer = {}
		controller.cooldownActive = true
		controller.cooldownTimer = input_system.inputCooldown
	end
end

-- Calcula o próximo movimento com base nos inputs
function input_system.getNextMove(controller, gridX, gridY, map_manager, bomb_manager)
	if #controller.inputQueue == 0 then return nil end

	-- Se estiver em cooldown, não inicia movimentos novos
	if controller.cooldownActive then
		return nil
	end

	-- Variáveis para determinar a próxima posição
	local nextX, nextY = gridX, gridY
	local direction = nil

	-- Tenta APENAS o input mais recente (mais restritivo)
	local input = controller.inputQueue[1]

	local testX, testY = gridX, gridY
	local testDirection = nil

	if input == "up" then
		testY = testY - 1
		testDirection = "up"
	elseif input == "down" then
		testY = testY + 1
		testDirection = "down"
	elseif input == "left" then
		testX = testX - 1
		testDirection = "left"
	elseif input == "right" then
		testX = testX + 1
		testDirection = "right"
	end

	-- Verifica se podemos ir para esta direção
	if map_manager:isEmpty(testX, testY) and not bomb_manager:hasBomb(testX, testY) then
		nextX = testX
		nextY = testY
		direction = testDirection
	else
		return nil -- Se o input mais recente não for válido, não move
	end

	-- Se não encontrou nenhum movimento possível com inputs atuais
	if nextX == gridX and nextY == gridY then
		return nil
	end

	return nextX, nextY, direction
end

-- Verifica se o jogador pode fazer uma curva automática
function input_system.checkCornerTurn(controller, gridX, gridY, targetX, targetY, pixelX, pixelY, currentDirection,
									  map_manager, bomb_manager)
	local grid = require("src.utils.grid")

	-- Calcula o progresso do movimento atual (0.0 a 1.0)
	local targetPixelX, targetPixelY = grid.toPixel(targetX, targetY)
	local startPixelX, startPixelY = grid.toPixel(gridX, gridY)

	local totalDistX = targetPixelX - startPixelX
	local totalDistY = targetPixelY - startPixelY
	local currentDistX = pixelX - startPixelX
	local currentDistY = pixelY - startPixelY

	local progress = 0
	if math.abs(totalDistX) > 0 then
		progress = math.abs(currentDistX / totalDistX)
	elseif math.abs(totalDistY) > 0 then
		progress = math.abs(currentDistY / totalDistY)
	end

	-- Se não estiver perto o suficiente do final do movimento, não faz curva
	-- Modificado para usar um threshold mais baixo (0.5) para detectar curvas mais cedo
	if progress < input_system.cornerThreshold then
		return nil
	end

	-- Verifica se temos algum input perpendicular à direção atual
	for _, input in ipairs(controller.inputQueue) do
		-- Pula se for a mesma direção ou oposta
		if input == currentDirection or
			(input == "up" and currentDirection == "down") or
			(input == "down" and currentDirection == "up") or
			(input == "left" and currentDirection == "right") or
			(input == "right" and currentDirection == "left") then
			goto continue
		end

		-- Testa se podemos fazer a curva
		local nextX, nextY = targetX, targetY

		if input == "up" then
			nextY = nextY - 1
		elseif input == "down" then
			nextY = nextY + 1
		elseif input == "left" then
			nextX = nextX - 1
		elseif input == "right" then
			nextX = nextX + 1
		end

		-- Verifica se a curva é possível
		if map_manager:isEmpty(nextX, nextY) and not bomb_manager:hasBomb(nextX, nextY) then
			-- Retorna as informações da curva e também o progresso atual
			-- para permitir uma curva suave
			return nextX, nextY, input, progress
		end

		::continue::
	end

	return nil
end

return input_system
