# CYCLE-207 — ThreadRow ownsAccessibility for list links

## Change
- ThreadRow.ownsAccessibility (default true for home).
- Search/Workspace links pass false and own VO + running traits.

## Gates
checks+build · `4452576a` · App/Atlas 214
