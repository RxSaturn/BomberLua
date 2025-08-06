# Documento de Design de Jogo (GDD) - Bomberman Clone em Lua/LÖVE

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Mecânicas de Jogo](#2-mecânicas-de-jogo)
3. [Arquitetura do Sistema](#3-arquitetura-do-sistema)
4. [Módulos e Componentes](#4-módulos-e-componentes)
5. [Implementação Detalhada](#5-implementação-detalhada)
6. [Próximas Etapas](#6-próximas-etapas)

---

## 1. Visão Geral

### 1.1 Conceito do Jogo

Bomberman é um jogo de ação e estratégia onde os jogadores navegam por um labirinto em grade, colocando bombas para destruir obstáculos e eliminar oponentes. Este projeto visa recriar essa experiência clássica utilizando Lua com o framework LÖVE2D.

### 1.2 Objetivos do Projeto

- Criar uma experiência fiel ao Bomberman clássico
- Suportar de 2 a 4 jogadores em modo local
- Implementar todas as mecânicas essenciais (bombas, explosões, power-ups)
- Criar uma estrutura de código modular e extensível

### 1.3 Escopo Atual

O projeto implementou até agora:
- Sistema de grade para o mapa
- Geração procedural de mapas com paredes destrutíveis e indestrutíveis
- Movimentação básica dos jogadores
- Sistema de colocação e explosão de bombas
- Detecção de colisões
- Sistema básico de múltiplos jogadores

---

## 2. Mecânicas de Jogo

### 2.1 Sistema de Grade

O jogo é construído em torno de uma grade retangular, normalmente de 15x13 células. Cada célula pode conter:

- **Espaço vazio**: Onde os jogadores podem se movimentar
- **Parede indestrutível**: Delimita o mapa e cria o padrão do labirinto
- **Parede destrutível**: Pode ser destruída por explosões e potencialmente liberar power-ups
- **Jogadores**: Controlados pelos usuários
- **Bombas**: Colocadas pelos jogadores
- **Explosões**: Resultado da detonação de bombas

### 2.2 Movimentação dos Jogadores

Os jogadores se movem de célula em célula na grade. O movimento é implementado com uma transição suave entre células, utilizando a posição atual e uma posição alvo.

- **Controles do Jogador 1**: Teclas de seta + Espaço (bomba)
- **Controles do Jogador 2**: WASD + Shift esquerdo (bomba)
- **Controles do Jogador 3**: IJKL + Shift direito (bomba)
- **Controles do Jogador 4**: Teclado numérico + 0 (bomba)

### 2.3 Sistema de Bombas

Cada jogador pode colocar bombas que explodem após um tempo determinado. As características principais são:

- **Temporizador**: Bombas explodem após 3 segundos
- **Alcance**: A explosão se propaga em quatro direções (cima, baixo, esquerda, direita)
- **Limite por jogador**: Inicialmente, cada jogador pode colocar apenas 1 bomba por vez
- **Reação em cadeia**: Explosões podem detonar outras bombas

### 2.4 Sistema de Explosões

As explosões:
- Se propagam nas quatro direções cardeais
- Param ao encontrar paredes indestrutíveis
- Destroem paredes destrutíveis
- Eliminam jogadores que são atingidos
- Têm duração limitada (0.5 segundos)

### 2.5 Condições de Vitória

- O último jogador vivo vence
- Se todos os jogadores morrerem simultaneamente, é considerado empate

---

## 3. Arquitetura do Sistema

### 3.1 Estrutura Modular

O projeto utiliza uma arquitetura modular baseada em componentes, onde diferentes aspectos do jogo são gerenciados por módulos específicos. Este design facilita a manutenção, extensibilidade e testabilidade do código.

```
game/
├── src/
│   ├── managers/
│   │   ├── map_manager.lua       # Gerencia o layout e os elementos do mapa
│   │   ├── bomb_manager.lua      # Gerencia as bombas e explosões
│   │   ├── player_manager.lua    # Gerencia os jogadores
│   ├── entities/
│   │   ├── player.lua            # Entidade do jogador
│   │   ├── bomb.lua              # Entidade da bomba
│   │   ├── explosion.lua         # Entidade da explosão
│   └── utils/
│       └── grid.lua              # Utilitários para a grade do jogo
```

### 3.2 Padrão de Gerenciadores (Manager Pattern)

O sistema emprega um padrão de design onde cada aspecto do jogo é gerenciado por um "manager" dedicado:

- **map_manager**: Gerencia o estado e renderização do mapa
- **bomb_manager**: Gerencia a criação, atualização e remoção de bombas e explosões
- **player_manager**: Gerencia os jogadores, seus estados e interações

### 3.3 Sistema de Entidades

As entidades principais (Player, Bomb, Explosion) são implementadas como objetos independentes com seus próprios métodos e estados:

- **Criação**: Através de métodos construtores (`:new()`)
- **Atualização**: Através de métodos de atualização (`:update()`)
- **Renderização**: Através de métodos de desenho (`:draw()`)

---

## 4. Módulos e Componentes

### 4.1 Utilitários (`grid.lua`)

Este módulo fornece funções para converter entre coordenadas de grade (lógicas) e coordenadas de pixel (renderização), além de verificar limites da grade.

#### Conceitos de Lua: Tabelas como Módulos

Em Lua, os módulos são implementados como tabelas que são retornadas ao final do arquivo. Isso permite encapsular funcionalidade relacionada.

```lua
local grid = {
    WIDTH = 15,       -- Largura do mapa em células
    HEIGHT = 13,      -- Altura do mapa em células
    TILE_SIZE = 32,   -- Tamanho de cada célula em pixels
}

-- Funções do módulo
function grid.toPixel(gridX, gridY)
    return (gridX - 1) * grid.TILE_SIZE, (gridY - 1) * grid.TILE_SIZE
end

-- Retorna o módulo ao final
return grid
```

### 4.2 Gerenciador de Mapa (`map_manager.lua`)

#### Principais Responsabilidades:
- Inicializar o mapa com paredes destrutíveis e indestrutíveis
- Verificar disponibilidade de células para movimento
- Lidar com a destruição de paredes
- Desenhar o mapa

#### Métodos Principais:

**`map_manager:init()`**
- **Propósito**: Inicializa o mapa com um padrão específico de paredes
- **Funcionamento**: Cria uma matriz 2D com diferentes valores para cada tipo de célula (0: vazio, 1: parede indestrutível, 2: parede destrutível)
- **Algoritmo**: 
  - Cria paredes indestrutíveis nas bordas
  - Coloca paredes indestrutíveis em posições ímpares (x,y) para criar o padrão clássico do Bomberman
  - Distribui paredes destrutíveis aleatoriamente nas células restantes com 70% de probabilidade
  - Limpa as áreas de spawn para os jogadores

**`map_manager:clearSpawnAreas()`**
- **Propósito**: Garante que os jogadores tenham espaço para se movimentar quando o jogo começa
- **Funcionamento**: Define células específicas como vazias (0) para cada posição inicial de jogador

**`map_manager:isWall(gridX, gridY)`**
- **Propósito**: Verifica se uma posição contém uma parede
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se há uma parede na posição

**`map_manager:isEmpty(gridX, gridY)`**
- **Propósito**: Verifica se uma posição está vazia
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se a célula está vazia

**`map_manager:destroyWall(gridX, gridY)`**
- **Propósito**: Destrói uma parede destrutível em uma posição específica
- **Parâmetros**: Coordenadas da grade
- **Funcionamento**: Converte paredes destrutíveis (2) em espaços vazios (0)
- **Retorno**: Boolean indicando sucesso da operação

**`map_manager:draw()`**
- **Propósito**: Renderiza o mapa na tela
- **Funcionamento**: Percorre a matriz de tiles e desenha cada um com a cor apropriada

### 4.3 Gerenciador de Bombas (`bomb_manager.lua`)

#### Principais Responsabilidades:
- Gerenciar a colocação, atualização e explosão de bombas
- Criar e gerenciar explosões
- Verificar colisões entre explosões e jogadores/paredes

#### Métodos Principais:

**`bomb_manager:init()`**
- **Propósito**: Inicializa as listas de bombas e explosões

**`bomb_manager:hasBomb(gridX, gridY)`**
- **Propósito**: Verifica se já existe uma bomba na posição especificada
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando a presença de uma bomba

**`bomb_manager:placeBomb(gridX, gridY, power, owner)`**
- **Propósito**: Coloca uma nova bomba no mapa
- **Parâmetros**: 
  - `gridX, gridY`: Posição na grade
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que colocou a bomba
- **Retorno**: Boolean indicando sucesso da operação

**`bomb_manager:createExplosion(gridX, gridY, power, owner, map_manager)`**
- **Propósito**: Cria uma explosão e a propaga nas quatro direções
- **Parâmetros**: 
  - `gridX, gridY`: Origem da explosão
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que causou a explosão
  - `map_manager`: Referência ao gerenciador de mapa para interagir com paredes
- **Algoritmo**:
  1. Cria explosão central
  2. Para cada direção (cima, baixo, esquerda, direita):
     - Propaga explosão até encontrar parede indestrutível
     - Se encontrar parede destrutível, a destrói e encerra propagação naquela direção
     - Se encontrar outra bomba, inicia sua detonação (reação em cadeia)

**`bomb_manager:isPlayerHit(gridX, gridY)`**
- **Propósito**: Verifica se um jogador na posição especificada seria atingido por explosão
- **Parâmetros**: Coordenadas da grade
- **Retorno**: Boolean indicando se há explosão na posição

**`bomb_manager:update(dt, map_manager, player_manager)`**
- **Propósito**: Atualiza todas as bombas e explosões no mapa
- **Parâmetros**:
  - `dt`: Delta time (tempo desde último frame)
  - `map_manager`: Referência ao gerenciador de mapa
  - `player_manager`: Referência ao gerenciador de jogadores
- **Funcionamento**:
  1. Atualiza cada bomba (reduz timer)
  2. Detona bombas com timer <= 0
  3. Atualiza cada explosão (reduz timer)
  4. Remove explosões com timer <= 0

**`bomb_manager:draw()`**
- **Propósito**: Renderiza todas as bombas e explosões

### 4.4 Gerenciador de Jogadores (`player_manager.lua`)

#### Principais Responsabilidades:
- Gerenciar a criação e estado de todos os jogadores
- Processar entrada para controlar jogadores
- Verificar condições de fim de jogo

#### Conceitos de Lua: Passagem de Referência

Em Lua, as tabelas (como nossos gerenciadores) são passadas por referência, não por valor. Isso permite que diferentes módulos compartilhem e modifiquem o mesmo objeto.

```lua
-- O bomb_manager original é passado, não uma cópia
player_manager:update(dt, map_manager, bomb_manager)
```

#### Métodos Principais:

**`player_manager:init()`**
- **Propósito**: Inicializa o gerenciador de jogadores
- **Funcionamento**: Cria o primeiro jogador por padrão

**`player_manager:addPlayer(id)`**
- **Propósito**: Adiciona um novo jogador ao jogo
- **Parâmetros**: ID do jogador (1-4)
- **Retorno**: Referência ao novo jogador ou nil se falhar

**`player_manager:decrementBombs(playerId)`**
- **Propósito**: Decrementa o contador de bombas ativas de um jogador
- **Parâmetros**: ID do jogador
- **Funcionamento**: Permite que o jogador coloque mais bombas quando as anteriores explodem

**`player_manager:checkExplosionHits(bomb_manager)`**
- **Propósito**: Verifica se algum jogador foi atingido por explosões
- **Parâmetros**: Referência ao gerenciador de bombas
- **Funcionamento**: Para cada jogador vivo, verifica se sua posição coincide com alguma explosão

**`player_manager:update(dt, map_manager, bomb_manager)`**
- **Propósito**: Atualiza todos os jogadores e verifica condições de fim de jogo
- **Parâmetros**:
  - `dt`: Delta time (tempo desde último frame)
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas

**`player_manager:checkGameOver()`**
- **Propósito**: Verifica se o jogo acabou
- **Funcionamento**: 
  - Se restar apenas um jogador vivo, ele é declarado vencedor
  - Se todos os jogadores morrerem, é declarado empate

**`player_manager:keypressed(key, map_manager, bomb_manager)`**
- **Propósito**: Processa teclas pressionadas para todos os jogadores
- **Parâmetros**:
  - `key`: Tecla pressionada
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas

**`player_manager:restart()`**
- **Propósito**: Reinicia todos os jogadores para uma nova partida

### 4.5 Entidade Jogador (`player.lua`)

#### Conceitos de Lua: Metatables e Herança

Lua implementa herança usando metatables. A função `setmetatable(objeto, {__index = classe})` permite que o `objeto` herde métodos e propriedades da `classe`.

```lua
function player:new(id)
    local newPlayer = {
        id = id,
        -- Outras propriedades...
    }
    
    setmetatable(newPlayer, self)
    self.__index = self
    
    return newPlayer
end
```

#### Atributos Principais:
- `id`: Identifica o jogador (1-4)
- `gridX, gridY`: Posição atual na grade
- `targetX, targetY`: Posição alvo para movimento
- `pixelX, pixelY`: Posição exata em pixels para renderização suave
- `isAlive`: Estado do jogador
- `maxBombs`: Número máximo de bombas que o jogador pode colocar
- `currentBombs`: Número de bombas atualmente ativas
- `bombPower`: Alcance da explosão das bombas do jogador

#### Métodos Principais:

**`player:new(id)`**
- **Propósito**: Construtor para criar um novo jogador
- **Parâmetros**: ID do jogador
- **Retorno**: Nova instância de jogador

**`player:init(id)`**
- **Propósito**: Inicializa ou reinicia o jogador
- **Parâmetros**: ID do jogador
- **Funcionamento**: Define posição inicial com base no ID do jogador

**`player:kill()`**
- **Propósito**: Mata o jogador
- **Funcionamento**: Define `isAlive` como false

**`player:placeBomb(map_manager, bomb_manager)`**
- **Propósito**: Tenta colocar uma bomba na posição atual do jogador
- **Parâmetros**: Referências aos gerenciadores necessários
- **Retorno**: Boolean indicando sucesso da operação

**`player:update(dt, map_manager, bomb_manager)`**
- **Propósito**: Atualiza o jogador - movimento e transição suave
- **Parâmetros**:
  - `dt`: Delta time
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Funcionamento**:
  1. Se o jogador estiver se movendo, continua a transição para a célula alvo
  2. Se não estiver se movendo, processa entrada para determinar próxima direção
  3. Verifica se o movimento é possível (sem colisões)

**`player:getPlayerKeys()`**
- **Propósito**: Retorna o mapeamento de teclas para este jogador
- **Retorno**: Tabela com mapeamentos de direções e ação de bomba

**`player:keypressed(key, map_manager, bomb_manager)`**
- **Propósito**: Processa tecla pressionada específica para este jogador
- **Parâmetros**:
  - `key`: Tecla pressionada
  - `map_manager`: Referência ao gerenciador de mapa
  - `bomb_manager`: Referência ao gerenciador de bombas
- **Funcionamento**: Se a tecla corresponder ao controle de bomba deste jogador, tenta colocar uma bomba

**`player:draw()`**
- **Propósito**: Renderiza o jogador na tela
- **Funcionamento**: Desenha um círculo colorido com um indicador de direção

### 4.6 Entidade Bomba (`bomb.lua`)

#### Atributos Principais:
- `gridX, gridY`: Posição na grade
- `timer`: Tempo até explosão (em segundos)
- `power`: Alcance da explosão
- `owner`: ID do jogador que colocou a bomba

#### Métodos Principais:

**`bomb:new(gridX, gridY, power, owner)`**
- **Propósito**: Construtor para criar uma nova bomba
- **Parâmetros**:
  - `gridX, gridY`: Posição na grade
  - `power`: Alcance da explosão
  - `owner`: ID do jogador que colocou a bomba
- **Retorno**: Nova instância de bomba

**`bomb:update(dt)`**
- **Propósito**: Atualiza o temporizador da bomba
- **Parâmetros**: Delta time
- **Retorno**: Boolean indicando se a bomba deve explodir

**`bomb:draw()`**
- **Propósito**: Renderiza a bomba na tela
- **Funcionamento**: Desenha um círculo preto com um pavio, que pisca mais rápido conforme se aproxima da explosão

### 4.7 Entidade Explosão (`explosion.lua`)

#### Atributos Principais:
- `gridX, gridY`: Posição na grade
- `timer`: Duração da explosão (em segundos)
- `type`: Tipo de explosão (centro, horizontal, vertical)

#### Métodos Principais:

**`explosion:new(gridX, gridY, type)`**
- **Propósito**: Construtor para criar uma nova explosão
- **Parâmetros**:
  - `gridX, gridY`: Posição na grade
  - `type`: Tipo de explosão
- **Retorno**: Nova instância de explosão

**`explosion:update(dt)`**
- **Propósito**: Atualiza o temporizador da explosão
- **Parâmetros**: Delta time
- **Retorno**: Boolean indicando se a explosão acabou

**`explosion:draw()`**
- **Propósito**: Renderiza a explosão na tela
- **Funcionamento**: Desenha retângulos coloridos (laranja/amarelo) para representar o fogo da explosão

---

## 5. Implementação Detalhada

### 5.1 Ciclo de Vida do Jogo

O ciclo de vida é gerenciado pelo LÖVE framework através das funções de callback:

- **`love.load()`**: Inicializa os gerenciadores e estados iniciais
- **`love.update(dt)`**: Atualiza o estado do jogo a cada frame
- **`love.draw()`**: Renderiza o jogo na tela
- **`love.keypressed(key)`**: Processa teclas pressionadas
- **`love.keyreleased(key)`**: Processa teclas liberadas

### 5.2 Sistema de Movimento

#### Conceitos de Lua: Delta Time

Em Lua e LÖVE, o parâmetro `dt` (delta time) representa o tempo decorrido desde o último frame. Multiplicar velocidades por `dt` garante um movimento consistente independente da taxa de quadros.

```lua
local moveAmount = self.speed * grid.TILE_SIZE * dt
```

O movimento do jogador é implementado com uma transição suave:

1. O jogador tem uma posição atual (`gridX`, `gridY`) e uma posição alvo (`targetX`, `targetY`)
2. Quando um movimento é solicitado, verifica-se a viabilidade (sem colisões)
3. Se possível, a posição alvo é atualizada e a flag `isMoving` é ativada
4. Durante o estado de movimento, a posição em pixels (`pixelX`, `pixelY`) é interpolada em direção à posição alvo
5. Quando o jogador chega ao destino, as coordenadas de grade são atualizadas e `isMoving` é desativada

### 5.3 Sistema de Colisão

As colisões são verificadas em vários níveis:

1. **Colisão com paredes**: Verifica se uma célula contém uma parede
   ```lua
   if map_manager:isWall(newTargetX, newTargetY) then
       return false
   end
   ```

2. **Colisão com bombas**: Verifica se uma célula contém uma bomba
   ```lua
   if bomb_manager:hasBomb(newTargetX, newTargetY) then
       return false
   end
   ```

3. **Colisão com explosões**: Verifica se um jogador está em uma célula com explosão
   ```lua
   if bomb_manager:isPlayerHit(player.gridX, player.gridY) then
       player:kill()
   end
   ```

### 5.4 Sistema de Propagação de Explosões

A propagação de explosões é implementada usando um algoritmo de "flood fill" direcionado:

1. A explosão começa no centro (posição da bomba)
2. Para cada uma das quatro direções cardeais (cima, baixo, esquerda, direita):
   - A explosão se propaga até o alcance máximo ou até encontrar um obstáculo
   - Se encontrar uma parede indestrutível, para naquela direção
   - Se encontrar uma parede destrutível, destrói a parede e para naquela direção
   - Se encontrar outra bomba, aciona a detonação imediata dela (reação em cadeia)

### 5.5 Controles de Múltiplos Jogadores

O sistema suporta até quatro jogadores locais, cada um com seu próprio conjunto de controles:

- **Jogador 1**: Setas direcionais + Espaço (bomba)
- **Jogador 2**: WASD + Shift esquerdo
- **Jogador 3**: IJKL + Shift direito
- **Jogador 4**: Numpad (8,5,4,6) + Numpad 0

Cada jogador é identificado por uma cor:
- Jogador 1: Vermelho
- Jogador 2: Azul
- Jogador 3: Verde
- Jogador 4: Amarelo

### 5.6 Geração de Mapa

O mapa é gerado com um padrão específico que é característico do Bomberman:

1. **Borda externa**: Paredes indestrutíveis
2. **Padrão interno**: Paredes indestrutíveis em coordenadas (x,y) onde ambas são ímpares
3. **Paredes destrutíveis**: Distribuídas aleatoriamente com 70% de chance
4. **Áreas de spawn**: Células vazias garantidas nas posições iniciais dos jogadores

---

## 6. Próximas Etapas

### 6.1 Sistema de Power-ups

Implementar power-ups que aparecem quando paredes destrutíveis são destruídas:

- **Bomba Extra**: Aumenta o número máximo de bombas
- **Aumento de Alcance**: Aumenta o raio da explosão das bombas
- **Aumento de Velocidade**: Torna o jogador mais rápido
- **Power-ups Especiais**: Chute de bomba, passe através de bombas, etc.

### 6.2 Melhoria Visual

- Substituir formas geométricas por sprites
- Adicionar animações para jogadores, bombas e explosões
- Implementar efeitos visuais (partículas, shake, etc.)

### 6.3 Menu e Interface

- Tela de título
- Menu de seleção de jogadores
- HUD durante o jogo
- Tela de fim de partida mais elaborada

### 6.4 Áudio

- Efeitos sonoros para ações (movimento, colocação de bombas, explosões)
- Música de fundo
- Sons de vitória/derrota

### 6.5 Refinamento de Mecânicas

- Ajuste fino do balanceamento (velocidade, tempo de bomba, etc.)
- Modos de jogo adicionais (tempo limite, morte súbita)
- Customização de controles

---

## Conclusão

Este documento descreve o design e a implementação atual de um clone do Bomberman em Lua/LÖVE, detalhando as mecânicas principais, a arquitetura modular do sistema e os componentes individuais. A estrutura modular adotada facilita a extensão e manutenção do código, permitindo adicionar novas funcionalidades e refinar as existentes.

O projeto até agora implementou com sucesso as mecânicas fundamentais do Bomberman, incluindo movimento em grade, colocação de bombas, propagação de explosões e suporte a múltiplos jogadores. As próximas etapas focarão em expandir essas funcionalidades e melhorar a experiência visual e sonora do jogo.
