# BomberLua

Um clone do clássico Bomberman desenvolvido em Lua utilizando o framework LÖVE2D.

## Sobre o Projeto

BomberLua foi desenvolvido como projeto da disciplina de Paradigmas da Programação do IFMG Campus Bambuí. O objetivo principal foi explorar a linguagem Lua e suas aplicações no desenvolvimento de jogos, utilizando o framework LÖVE2D como base para implementação.

O projeto permitiu aprofundar conhecimentos sobre programação orientada a eventos, gerenciamento de estados e recursos, além de práticas de desenvolvimento de jogos como sistemas de colisão, movimentação em grade e feedback visual para o jogador.

## Características do Jogo

- Gameplay baseado em grade com paredes destrutíveis e indestrutíveis
- Multiplayer local suportando de 2 a 4 jogadores
- Mecânicas clássicas de bombas com explosões, reações em cadeia e power-ups
- Movimentação suave dos jogadores e animações
- Sistema de power-ups (alcance de bomba, quantidade, e aumentos de velocidade)

## Documentação de Design (GDD)

O desenvolvimento do BomberLua foi guiado por um Documento de Design de Jogo (GDD) detalhado que pode ser encontrado na pasta `/GDD`. Este documento serviu como referência durante todo o processo de desenvolvimento, definindo o escopo do projeto, mecânicas de jogo, arquitetura do sistema e implementações técnicas necessárias.

O GDD foi fundamental para manter o foco nos objetivos principais e garantir uma implementação consistente das mecânicas propostas.

## Como Começar

### Pré-requisitos
- [Visual Studio Code](https://code.visualstudio.com/download)
- [LÖVE 11.4](https://love2d.org/)
- [Makelove](https://github.com/pfirsich/makelove) (opcional para builds)
- [NPM](https://nodejs.org/en/download) (opcional)

**LÖVE e Makelove devem estar na variável de ambiente PATH.**

### Configurando o ambiente

1. Clone este repositório para sua máquina local:
```
git clone https://github.com/RxSaturn/BomberLua.git
```

2. Abra o arquivo `Workspace.code-workspace` com o Visual Studio Code.
   Você receberá uma mensagem sobre extensões recomendadas. Clique em 'Instalar'.
   
   Se isso não acontecer, instale manualmente as extensões [Sumneko Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua), [Local Lua Debugger](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode) e [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig).

3. Configure a variável de ambiente PATH para incluir o diretório de instalação do LÖVE2D:

![Configurando PATH](https://sheepolution.com/images/book/bonus/vscode/lovepath.gif)

### Executando o jogo

Existem duas maneiras de executar o jogo:

1. **Usando o VS Code**:
   - Abra o workspace no VS Code
   - Pressione `F5` para iniciar o jogo no modo Debug
   - Você pode alternar para o modo Release na aba "Run and Debug" (`Ctrl+Shift+D`)

2. **Diretamente pelo LÖVE**:
   - Arraste a pasta `game` para o executável do LÖVE
   - Ou, via linha de comando: `love caminho/para/pasta/game`

## Estrutura do Projeto
```
├── /game
│   ├── /assets         Contém os assets do jogo
│   ├── /lib            Contém bibliotecas externas
│   └── /src            Contém o código-fonte do jogo
│       ├── /effects    Sistema de partículas e efeitos visuais
│       ├── /entities   Entidades do jogo (jogador, bomba, etc.)
│       ├── /managers   Gerenciadores (mapa, bombas, jogadores, etc.)
│       ├── /systems    Sistemas de apoio (input, colisão, etc.)
│       └── /utils      Funções utilitárias
│
├── /GDD                Documentação de design do jogo
│
├── /tools              Ferramentas de build e suporte
│
└── /resources          Recursos para o desenvolvimento
```

## Controles de Jogo

- **Jogador 1**: Teclas de seta + Espaço (bomba)
- **Jogador 2**: WASD + Shift esquerdo (bomba)
- **Jogador 3**: IJKL + Shift direito (bomba)
- **Jogador 4**: Teclado numérico + 0 (bomba)

Para adicionar mais jogadores durante o jogo:
- Tecla "2": Adiciona o segundo jogador
- Tecla "3": Adiciona o segundo e terceiro jogadores
- Tecla "4": Adiciona o segundo, terceiro e quarto jogadores

Outros comandos:
- **R**: Reinicia o jogo
- **ESC**: Sai do jogo
