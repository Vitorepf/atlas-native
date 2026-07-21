# WAVE-003 — conversation-sink

**Status:** design approved  
**Wave:** `WAVE-003-conversation-sink`  
**Date:** 2026-07-21  

## Problema

Conversa é o órgão diário — empty · load fail · stale · composer · cockpit. Já usa `AtlasNetworkFailureEmpty` no load, mas:

1. `EmptyConversation` is a **10-file peel tower** for one empty face.
2. Cockpit is **~50 peels** (watchdog/strip/ribbon micro-towers).
3. Glass/header mostly settled; fidelity risk is peel fog + accidental empty/stale collision.

## Patamar

Um sink legível: empty editorial honesto · fail network canônico · cockpit só com sinal real · W3 fuse sem god-file.

## Arquitetura

- Manter `AtlasNetworkFailureEmpty` no load path (já correto).
- Fuse `EmptyConversation` 10→1–2 files.
- Fuse `ConversationMessages+Empty*` se trivial.
- W3: fuse Cockpit watchdog micro-peels + adjacent empty/chrome 1-string peels.
- Zero `ConversationModel` / Core.

## DoD (≥5)

1. Load fail still `AtlasNetworkFailureEmpty` + kind + retry.
2. Empty idle still `EmptyConversation` with caller prompt/suggestions (pack from WAVE-002 hosts).
3. Empty≠load-fail (no collision).
4. Reduce motion respected on breathe.
5. A11y prompt/suggestions stable.
6. W3: EmptyConversation peels collapsed; Cockpit watchdog peels collapsed; no View/Shell >400.
7. Gates green.

## Anti-objetivos

- Rewriting ConversationModel logic.
- Collapsing empty into network failure.
- God-files >400.
- Fake live strip without model signal.

## Plano W3

Target −400 to −800 LOC from Empty+Cockpit watchdog/composer micro peels. Honest numstat if less (WAVE-001 lesson).

## Gates

guard · AtlasCoreChecks · make build
