# CYCLE-433

## D1 Sense
- Search field capsule sat flat next to elevated glass back button.
- ArtifactSheet toast lacked the conversation toast elevation plane.
- Arena premium tab track and run-submit CTA were recessed/flat vs other floating chrome.

## D2 Choose
soft craft: shared elevation plane for search glass + residual floating chrome (toast/CTA/tab track).

## D3 Do
- `RootView.searchFieldCapsule`: focus-reactive `.atlasElevation` (6/0.12 → 10/0.16).
- `ArtifactSheet.toast`: elevation 10/3/0.2 (match conversation toast).
- Arena tab track: soft elevation 6/2/0.1.
- Arena `submitButtonLabel` (“Rodar medição”): elevation 10/3, stronger when valid.

## D4 Gates
- `swift run AtlasCoreChecks` ✓
- `cd App && make build` ✓

## D5 Commit
- `71e62bf9` polish(ui): search field focus elevation; artifact toast + Arena CTA lift

## D6 Ledger
- App/Atlas Swift: 36
- next: residual craft (more flat capsules / glow / natural-case residuals)
- not done
