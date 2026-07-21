# CYCLE-434

## D1 Sense
- Code load-failure “Tentar de novo” sat flat vs network-failure empty CTA elevation.
- Autonomos quiet secondary CTAs had stroke only — no shared depth with primary map CTAs.
- Radar violating status capsule needed soft attention lift.

## D2 Choose
soft craft: recovery + secondary CTA elevation + radar alert capsule.

## D3 Do
- `AtlasCodeView` load retry: elevation 8/2/0.14.
- `AutonomosMapQuietCTA`: elevation 8/2, 0.12 danger / 0.06 quiet.
- Radar violating status: elevation 6/2/0.12.

## D4 Gates
- AtlasCoreChecks ✓ · make build ✓

## D5 Commit
- `a186232a` polish(ui): Code retry elevation; quiet Autonomos CTA; radar alert lift

## D6 Ledger
- App/Atlas Swift: 36 · residual craft · not done
