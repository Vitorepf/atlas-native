# CYCLE-002 — LEAP #1 honesty silenciar→pausar

## Product jump
Mute action on nightly proposal card said **silenciar**; status already said
**propostas em pausa**. Align verb with state: operator pauses proposals.

## Changes (casca only)
- Menu label: `pausar`
- VoiceOver: `pausar propostas noturnas` / `pausar por N dias`
- Status: `propostas noturnas em pausa até …` (manual mute)
- Silêncio as healthy *state* kept in discard hints (not a button verb)

## Out of scope
No model mute API rename (AtlasSession.mute* stays — Codex seam).
