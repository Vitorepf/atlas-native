# Atlas Native — motion/haptics map

Mapa curto dos movimentos e haptics existentes na casca. Serve para manter a
gramática consistente sem transformar cada microinteração em regra nova.

## Motion

- **Entrada editorial:** `AtlasMotion.arrival` para turnos/cards que chegam.
- **Respiração viva:** `BreathingGlyph` e `BreathingDiamond` somente para estado
  vivo/espera ativa; respeitam Reduce Motion.
- **Transições numéricas:** contadores/timers usam `.numericText()` e
  `.monospacedDigit()` quando mudam com frequência.
- **Scroll de conversa/timeline:** animações curtas (`0.15s`–`0.25s`) e
  coalescidas; Reduce Motion troca por atualização direta.
- **Sheets/sheets de prova:** abertura padrão do sistema; não duplicar com
  animação custom.

## Haptics

- **Ação primária / envio:** `UIImpactFeedbackGenerator(style: .medium)`.
- **Ação secundária / filtros / abrir detalhe:** `style: .soft`.
- **Ciclo concluído:** `UINotificationFeedbackGenerator().notificationOccurred(.success)`.
- **Copiar / feedback explícito:** impacto médio ou leve conforme a superfície.

## Guardrails

- Não usar haptic em estado passivo que apenas carrega ou atualiza por polling.
- Não animar timers em Reduce Motion; preservar texto e dados.
- Todo botão que executa ação governada precisa ter feedback visual mesmo sem haptic.
