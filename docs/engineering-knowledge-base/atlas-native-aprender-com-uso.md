# Aprender com o uso — ritmo do dia + proposta noturna (atlas-native)

Direção canônica aprovada pelo operador (2026-07-17): o diferencial do Autônomos
não é mais dado na tela — é o app **percebendo o operador**. Este doc é o owner
doc dessa camada na casca.

## Arquitetura

| Peça | Onde | Papel |
|------|------|-------|
| `AtlasDayRhythm` (actor) | `Sources/AtlasCore/AtlasDayRhythm*.swift` | Registra primeira/última atividade por dia (14 dias, local-only em Application Support). `windows(minimumDays: 4)` → mediana de início/fim dos últimos 7 dias. |
| Registro de atividade | `AtlasSession.swift` (abertura) + `ConversationModel+Execute.swift` (turno executado, com workspace) | Alimenta o ritmo com uso real — nunca com inferência. |
| Linha de ritmo | `AutonomosAwaitingSection+Rhythm.swift` | Autossuficiente (busca as janelas sozinha). Aprendendo: "dia N de 4". Aprendida: "seu dia termina ~HH:MM". Nunca some — amadurece. |
| Folha "O ritmo do seu dia" | `AutonomosRhythmSheet.swift` + `+Copy.swift` | O que foi aprendido (janelas, amostra), hoje (workspaces), placar de propostas, o que o Atlas faz com isso, status/undo do silêncio, garantia local-only dita na tela. |
| Proposta noturna | `NightlyProposal*.swift` | No fim do dia aprendido, se houve trabalho hoje → notificação + card "Preparar missão noturna". Aceite agenda o digest matinal no início do dia aprendido. |
| Aprender com as respostas | `AtlasSession+NightlyDecisions.swift` + `NightlyProposal.swift` | Streak de recusas (3 seguidas → pausa automática de 7 dias, **dita** na folha do ritmo); aceite zera o streak; placar total aceitas·recusadas. |
| Janela adaptativa | `AtlasSession+NightlyDecisions.swift` + `NightlyProposal+ScheduleTrigger.swift` | Mediana dos atrasos proposta→aceite (últimos 5; clamp 0…60 min, passo 5, ≥2 amostras) desliza o gatilho noturno para o horário real de resposta. Dita na folha: "ajuste: +N min". |

## Princípios (não negociar)

1. **Visível quando existe** — aprendizado completo não desaparece; vira informação.
2. **Honesto quando incompleto** — "dia N de 4", nunca janela inventada (C13).
3. **Local-only declarado** — o dado nunca sai do iPhone e a tela diz isso.
4. **Sempre com caminho de volta** — pausa automática e mute manual têm o botão
   "Reativar propostas noturnas" na folha do ritmo. Silêncio inexplicado é bug.
5. **Backoff é aprendizado, não punição** — 3 recusas seguidas ensinam que o
   momento está errado; a copy diz o porquê e o prazo de volta.

## Contratos de teste

- A11y: `autonomos-rhythm-line` · `autonomos-rhythm-sheet` · `autonomos-rhythm-unmute`.
- XCUITest: `App/UITests/AtlasRhythmSheetTests.swift` (linha → folha → fechar).
- O target `AtlasDeviceProof` inclui a família `A11yID*.swift` inteira
  (project.yml) — só o base compilado quebra a bateria em silêncio.

## Chaves locais (UserDefaults, todas `atlas.nightlyProposal.*`)

`mutedUntil` · `dismissStreak` · `acceptedTotal` · `dismissedTotal` · `autoPaused` · `acceptDelays`.

## Próximas explorações candidatas

- Ritmo alimentar widget/Dynamic Island (bloqueado: App Group pendente no portal Apple).
- Ritmo por dia da semana (sexta ≠ segunda) quando houver ≥ 2 semanas de amostra.
- Digest matinal citar o que a frota entregou de fato durante a noite.

Entregas: commits `3bb7b6c` · `31297a2` · `f498bfd` · `9b83e66` · `ca6d491` (triagem
de erro + masthead no ritmo real + pausa ambiental) · `f322c29` (janela adaptativa)
— OBRA §7, 2026-07-17.
