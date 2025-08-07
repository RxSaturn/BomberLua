local lighting = {
	lights = {},
	ambient = { 0.7, 0.7, 0.7 } -- Luz ambiente
}

-- Adiciona uma nova fonte de luz
function lighting.addLight(x, y, radius, r, g, b, duration)
	local light = {
		x = x,
		y = y,
		radius = radius,
		color = { r, g, b, 1 },
		duration = duration or nil,
		timer = duration or nil,
		originalRadius = radius
	}

	table.insert(lighting.lights, light)
	return #lighting.lights -- Retorna o ID da luz
end

-- Remove uma luz
function lighting.removeLight(id)
	if lighting.lights[id] then
		table.remove(lighting.lights, id)
		return true
	end
	return false
end

-- Atualiza todas as luzes
function lighting.update(dt)
	for i = #lighting.lights, 1, -1 do
		local light = lighting.lights[i]

		-- Se a luz tem duração, atualiza o timer
		if light.timer then
			light.timer = light.timer - dt

			-- Diminui a intensidade conforme se aproxima do fim
			local factor = light.timer / light.duration
			light.color[4] = factor
			light.radius = light.originalRadius * (0.5 + factor * 0.5)

			-- Remove a luz quando o timer acaba
			if light.timer <= 0 then
				table.remove(lighting.lights, i)
			end
		end
	end
end

-- Renderiza o efeito de iluminação
function lighting.draw()
	love.graphics.setBlendMode("add")

	for _, light in ipairs(lighting.lights) do
		love.graphics.setColor(light.color[1] * 0.5, light.color[2] * 0.5,
			light.color[3] * 0.5, light.color[4] * 0.5)

		-- Gradiente de luz
		for i = 10, 1, -1 do
			local alpha = light.color[4] * (i / 10) * 0.2
			love.graphics.setColor(light.color[1], light.color[2], light.color[3], alpha)
			local size = light.radius * (i / 10)
			love.graphics.circle("fill", light.x, light.y, size)
		end
	end

	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1, 1)
end

return lighting
