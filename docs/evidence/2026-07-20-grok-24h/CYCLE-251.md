# CYCLE 251 — delete dead HomeAsk + residual APIs

## Hipótese
`HomeAskContext` never wired after pill inlining; more orphan helpers left.

## Deletes
- `App/Atlas/HomeAskContext.swift` (entire file, 0 external refs)
- `AtlasCodeRadarView.radarShellSpokenLabel` (contain-without-fuse leftover)
- `ArenaPremiumIconography.verified`
- `AtlasCodeWorkspaceCache.invalidate`
- `ChangeReviewModel.refreshArtifacts` (refreshChangeReview already loads artifacts)
- `AtlasMotion.ceremonial` / `sacred` unused duration tokens

## Next
Autônomos model methods with 0 call sites (transfer/decide/selectArea) — cycle 252

## Gates
checks + make build
