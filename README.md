# Arena do Caos

Projeto de jogo desenvolvido para Roblox utilizando Luau (strict mode) e sincronizado com o Roblox Studio via Rojo.

## Visao Geral

Arena do Caos e um jogo de sobrevivencia em arena baseado em rodadas, no qual os jogadores utilizam objetos arremessaveis com diferentes niveis de knockback e tempo de recarga para eliminar os adversarios da plataforma.

## Estrutura do Projeto

O mapeamento de pastas segue a configuracao definida em `default.project.json`:

- `src/server/` -> `ServerScriptService`
  - `RoundManager.lua`: Gerencia o loop principal de rodadas (`Intermission`, `InRound`, `RoundEnd`), teleporte para os spawns (`ArenaSpawns`), rastreamento de jogadores vivos e eliminacoes.
- `src/shared/` -> `ReplicatedStorage`
  - `Config/GameConfig.lua`: Modulo de configuracoes centrais (`table.freeze`) com regras de rodada, economia e catalogo de itens arremessaveis (Cadeira, Geladeira, Piano).
- `src/client/` -> `StarterPlayer.StarterPlayerScripts` (mapeado no `default.project.json`).

## Requisitos

- Roblox Studio
- Rojo (CLI e plugin no Roblox Studio)

## Como Executar

1. Inicie o servidor de sincronizacao do Rojo na raiz do projeto:

```bash
rojo serve
```

2. Abra o Roblox Studio, conecte o plugin do Rojo ao endereco padrao (`localhost:34872`) e inicie o teste (Play / Start Server).
3. Certifique-se de que exista uma pasta chamada `ArenaSpawns` no `Workspace` contendo `BasePart`s para o posicionamento dos jogadores no inicio de cada rodada.
