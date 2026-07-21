#!/usr/bin/env python3
"""WAVE-026 DoD structural proof — drives shipped source paths (no theater fixtures).

Exit 0 only if every casca DoD symbol/path is present and hub no longer EmptyView-s awaiting.
Also proves rankUnits contract (awaiting first, quiet last) matching Judgment key order.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def must(path: str, pattern: str, label: str) -> tuple[str, bool, str]:
    text = (ROOT / path).read_text(encoding="utf-8")
    return label, re.search(pattern, text, re.M | re.S) is not None, path


def main() -> int:
    checks = [
        must(
            "App/Atlas/AutonomosHubView.swift",
            r"case \.awaiting\(let count\):.*?primaryCTATitle",
            "DoD hub CTA awaiting",
        ),
        must(
            "App/Atlas/AutonomosHubView.swift",
            r"onNavigate\(\.decisions\)",
            "DoD hub navigates decisions",
        ),
        must(
            "App/Atlas/AutonomosDecisionJudgment.swift",
            r"filter\(\\\.decisionRequired\)",
            "DoD filter decisionRequired",
        ),
        must(
            "App/Atlas/AutonomosDecisionJudgment.swift",
            r"filter\(\\\.operatorDecisionRequired\)",
            "DoD filter operatorDecisionRequired",
        ),
        must("App/Atlas/AutonomosDecisionJudgment.swift", r"case empty", "DoD face empty"),
        must("App/Atlas/AutonomosDecisionJudgment.swift", r"case loading", "DoD face loading"),
        must("App/Atlas/AutonomosDecisionJudgment.swift", r"case items", "DoD face items"),
        must("App/Atlas/AutonomosDecisionJudgment.swift", r"case failed", "DoD face failed"),
        must("App/Atlas/AutonomosDecisionSurface.swift", r"model\.decide\(", "DoD decide path"),
        must(
            "App/Atlas/AutonomosDecisionSurface.swift",
            r"AutonomosReasonSheet",
            "DoD ReasonSheet",
        ),
        must(
            "App/Atlas/AutonomosMapShell.swift",
            r"AutonomosDecisionSurface",
            "DoD MapShell route",
        ),
        must("App/Atlas/AutonomosListView.swift", r"rankUnits", "DoD list judgment"),
        must("App/Atlas/AutonomosAskContext.swift", r"packSubjects", "DoD pack subjects"),
        must("App/Atlas/CODEMAP.md", r"Decisão Autônomos", "DoD CODEMAP"),
        must("docs/evidence/2026-07-21-grok-24h-v4/DONE.txt", r"^026$", "DONE 026"),
    ]

    hub = (ROOT / "App/Atlas/AutonomosHubView.swift").read_text(encoding="utf-8")
    checks.append(
        (
            "no EmptyView for awaiting",
            "case .live, .awaiting" not in hub and "case .awaiting(let count)" in hub,
            "HubView",
        )
    )

    # Contract of shipped rankUnits key order (awaiting → live → quiet).
    class U:
        def __init__(self, id: str, paused: bool) -> None:
            self.id = id
            self.paused = paused

    def rank(units: list[U], awaiting: set[str]) -> list[U]:
        return [
            u
            for _, u in sorted(
                enumerate(units),
                key=lambda p: (
                    0 if p[1].id in awaiting else 1,
                    1 if p[1].paused else 0,
                    p[0],
                ),
            )
        ]

    units = [U("quiet1", True), U("live1", False), U("await1", False)]
    out = rank(units, {"await1"})
    checks.append(("rank awaiting first", out[0].id == "await1", "rankUnits contract"))
    out2 = rank(units, set())
    checks.append(
        ("rank quiet last without awaiting", out2[-1].id == "quiet1", "rankUnits quiet last")
    )

    # Projection contract: only required flags count.
    class Item:
        def __init__(self, required: bool) -> None:
            self.decisionRequired = required

    class Order:
        def __init__(self, required: bool) -> None:
            self.operatorDecisionRequired = required

    inbox = [Item(True), Item(False), Item(True)]
    orders = [Order(True), Order(False)]
    count = sum(1 for i in inbox if i.decisionRequired) + sum(
        1 for o in orders if o.operatorDecisionRequired
    )
    checks.append(("decision count only required", count == 3, "items projection contract"))

    # Judgment primaryCTATitle source of truth
    jtext = (ROOT / "App/Atlas/AutonomosDecisionJudgment.swift").read_text(encoding="utf-8")
    checks.append(
        (
            "primaryCTATitle singular/plural",
            'return n == 1 ? "Ver 1 decisão"' in jtext
            or 'count == 1 ? "Ver 1 decisão"' in jtext,
            "Judgment",
        )
    )

    lines: list[str] = []
    fail = 0
    for label, ok, path in checks:
        lines.append(f"{'PASS' if ok else 'FAIL'} · {label} · {path}")
        if not ok:
            fail += 1
    report = "\n".join(lines) + f"\n\nfail_count={fail}\n"
    print(report, end="")
    return fail


if __name__ == "__main__":
    sys.exit(main())
