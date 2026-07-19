# Arena — Escala Humana e Gramática Iconográfica

## Objetivo

Tornar a leitura da Arena imediatamente humana e mais silenciosa sem alterar a
verdade dos contratos de medição. O servidor e o Core continuam transportando
scores normalizados em `0...1`; somente a apresentação no iPhone usa `0...10`.

## Régua pública

- Score normalizado `0.67` aparece como `6,7`.
- Score normalizado `1.00` aparece como `10`.
- Delta normalizado `-0.06` aparece como `-0,6`.
- Índices de destaque recebem o sufixo discreto `/10`.
- Linhas e comparações não repetem `/10`; a seção declara a escala uma vez.
- Multiplicadores continuam como razão, por exemplo `×1,08`.
- Progresso continua em `%`.
- Cobertura continua como contagem, por exemplo `10/10 suítes`.
- Ausência continua como `não medido`; nunca vira zero.

## Cor

- Dourado: seleção, ação primária ou estado realmente ativo.
- Coral: regressão, falha ou alerta real.
- Off-white e cinzas: navegação, métricas neutras e melhorias.
- Verde não aparece nas listas.
- Melhorias usam sinal `+`, texto e hierarquia; não dependem de verde.
- Sucesso terminal usa símbolo e copy explícita.

## Ícones

Toda iconografia interna da Arena passa por `ArenaPremiumIcon`.

- SF Symbols monocromáticos.
- Peso óptico `.medium`.
- Caixa regular `24 × 24 pt`.
- Símbolos de linha com tamanho nominal comum.
- Chevron único, com caixa e peso próprios, mas sempre produzido pelo mesmo
  componente.
- Variações maiores só existem para glifos hero/empty e preservam a mesma
  renderização monocromática.
- O mapa semântico de símbolos fica centralizado em
  `ArenaPremiumIconography`.

## Contratos e acessibilidade

- Nenhum DTO, schema, score persistido, ranking ou cálculo do servidor muda.
- VoiceOver fala scores como valor de zero a dez.
- Cor nunca é a única forma de distinguir melhoria, regressão ou sucesso.
- Os identificadores de automação existentes permanecem estáveis.

## Prova

- Checks focados de formatação em `AtlasCoreChecks`.
- `swift run AtlasCoreChecks`.
- `cd App && make build`.
- XCUITest Arena no Simulator para regressão funcional.
- Capturas reais das telas Agora, Resultados, Capacidades e detalhe.
- Build assinado, instalação e abertura no iPhone físico.

