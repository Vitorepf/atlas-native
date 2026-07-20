# Arena · Execução = mapa único (2026-07-20)

## Decisão do operador
A tela Execução do mockup (`docs/proposals/grok-arena-v1.html`) é a referência.
Agora só status + “Ver execução”. Detalhe mora na Execução. Pílula pergunta/age.

## Estrutura (de cima para baixo)
1. **AO VIVO** + motor (Fraunces)
2. **Herói** = casos da suíte ao vivo (`N de M` + `%`) + linha fina com o nome da suíte
3. **Parar** (só se o servidor declarar)
4. **Pipeline** = fase macro: Preparar → Sem Atlas → Com Atlas → Consolidar
5. **Corridas** = cada suíte·braço (feito / ao vivo / a seguir)
6. **Toque numa corrida** → detalhe com progresso e lista de casos (casos individuais = §5 Core)
7. **Pílula** = “pergunte sobre esta execução”

## Ícones
- **Corrida ao vivo:** `▸` (rodando) — nunca `✦` do Atlas
- **Pipeline “Com Atlas” ao vivo:** `✦` permitido (é o nome da fase)
- Feito `✓` · fila `◷` · pendente `○`

## Honestidade
Pipeline e corridas derivam só de `arenaPrimaryMeasurementRuns` (+ `activePlan` para braços esperados). Sem inventar casos; sem lista de testes até o contrato §5.
