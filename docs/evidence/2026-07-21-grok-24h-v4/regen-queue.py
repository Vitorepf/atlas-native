#!/usr/bin/env python3
"""Regenerate QUEUE.md + LEDGER.md from WAVE-*-design.md minus DONE.txt.

Designer-owned. Implementer appends NNN to DONE.txt when a wave lands,
then re-runs this script. Never hand-edit open ranks.
"""
from __future__ import annotations

import re
from pathlib import Path

EVID = Path(__file__).resolve().parent
TIER = {"max": 0, "high": 1, "med-high": 2, "med+": 3, "med": 4, "low": 5}


def load_done() -> set[str]:
    done: set[str] = set()
    p = EVID / "DONE.txt"
    if p.exists():
        for line in p.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            m = re.search(r"(\d{3})", line)
            if m:
                done.add(m.group(1))
    # compress files are also done
    for c in EVID.glob("WAVE-*-compress.md"):
        m = re.match(r"WAVE-(\d{3})-compress\.md", c.name)
        if m:
            done.add(m.group(1))
    return done


def parse_delta(text: str) -> str:
    m = re.search(r"\*\*Δ patamar:\*\*\s*\*\*([^*]+)\*\*", text)
    if not m:
        m = re.search(r"Δ patamar:\s*\*\*([^*]+)\*\*", text)
    raw = (m.group(1) if m else "med").strip().lower().replace("–", "-")
    if raw.startswith("max") or " max" in f" {raw}":
        # "max" or "max–high" → prefer max if starts with max
        if raw.startswith("max") and not raw.startswith("max-high") and "max–high" not in raw:
            # handle "max–high" after normalize
            pass
        if raw.startswith("max") and ("high" in raw and not raw.startswith("max ")):
            # max–high style
            if re.match(r"max[-\s]*high", raw):
                return "max"  # treat as max tier for ranking priority
        if raw.startswith("max"):
            return "max"
    if re.match(r"max[-\s]*high", raw):
        return "max"
    if raw.startswith("high"):
        return "high"
    if "med-high" in raw or re.match(r"med[-\s]*high", raw):
        return "med-high"
    if "med+" in raw or raw.startswith("med+"):
        return "med+"
    if raw.startswith("med"):
        return "med"
    if "low" in raw:
        return "low"
    return "med"


def parse_id(path: Path, text: str, num: str) -> str:
    m = re.search(r"\*\*Wave:\*\*\s*`([^`]+)`", text)
    if m:
        return m.group(1).strip()
    m = re.match(r"#\s*(WAVE-\d+)\s*[—\-]\s*(.+)", text.splitlines()[0])
    if m:
        slug = re.sub(r"[^a-z0-9]+", "-", m.group(2).strip().lower()).strip("-")
        return f"{m.group(1)}-{slug}"
    return f"WAVE-{num}"


def open_waves(done: set[str]) -> list[dict]:
    out = []
    for p in sorted(EVID.glob("WAVE-*-design.md")):
        m = re.match(r"WAVE-(\d{3})-design\.md", p.name)
        if not m:
            continue
        num = m.group(1)
        if num in done:
            continue
        text = p.read_text(encoding="utf-8")
        out.append(
            {
                "num": num,
                "id": parse_id(p, text, num),
                "delta": parse_delta(text),
                "design": f"docs/evidence/2026-07-21-grok-24h-v4/{p.name}",
            }
        )
    out.sort(key=lambda w: (TIER.get(w["delta"], 99), w["num"]))
    for i, w in enumerate(out, 1):
        w["rank"] = i
    return out


def write_queue(waves: list[dict], done: set[str]) -> None:
    lines = [
        "# Atlas Native — GOD WAVES v4 QUEUE",
        "",
        "> **Regenerated** from `WAVE-*-design.md` − `DONE.txt` (+ compress).",
        "> Re-run: `python3 docs/evidence/2026-07-21-grok-24h-v4/regen-queue.py`",
        "",
        "## Policy",
        "- Open ranking is mechanical (Δ order). Do not hand-rank.",
        "- Implementer: append NNN to DONE.txt after compress, re-run regen.",
        "- Designer never stages `App/**` or `Sources/**`.",
        "- Rank by Δ: max > high > med-high > med+ > med > low",
        "",
        "## Active",
        "- implementing: null",
        "",
        "## Queue (open · ranked by Δ · contiguous ranks 1…N)",
        "",
    ]
    if not waves:
        lines.append("_(no open proposed WAVEs)_")
        lines.append("")
    for w in waves:
        lines += [
            "```yaml",
            f"id: {w['id']}",
            "status: proposed",
            f"rank: {w['rank']}",
            f"delta_patamar: {w['delta']}",
            f"design: {w['design']}",
            "created_by: designer",
            "approved_at: null",
            "```",
            "",
        ]
    lines += [
        "## Candidates ranked (open only)",
        "",
        "| Rank | id | Δ | design |",
        "|---|---|---|---|",
    ]
    for w in waves:
        lines.append(
            f"| **{w['rank']}** | {w['id']} | **{w['delta']}** | `{Path(w['design']).name}` |"
        )
    lines += ["", "## History (done)", ""]
    for n in sorted(done):
        lines.append(f"- WAVE-{n} done")
    lines.append("")
    (EVID / "QUEUE.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_ledger(waves: list[dict], done: set[str]) -> None:
    n_designs = len(list(EVID.glob("WAVE-*-design.md")))
    lines = [
        "# Grok 24h v4 Dual — LEDGER",
        "",
        "Started: 2026-07-21T13:20:00Z",
        "mode: designer + implementer",
        "",
        "## Implementer",
        "- phase: idle",
        "- active_wave: null",
        f"- waves_completed: {len(done)}",
        "- idle_compress_passes: 2",
        "- collapse_host: 0",
        "",
        "## Waves done",
    ]
    for n in sorted(done):
        lines.append(f"- WAVE-{n}")
    lines += [
        "",
        "## Idle compress",
        "- pass 1 · `419bedf3`",
        "- pass 2 · `85be3450`",
        "",
        "## Designer",
        f"- designs_proposed: {n_designs}",
        f"- designs_open: {len(waves)}",
        "- last_regen: regen-queue.py (designs − DONE/compress)",
        "- policy: open ranking regenerated; never hand-stale tables",
        "",
        "## Open queue snapshot (must match QUEUE.md)",
        "",
        "| # | wave | Δ | status |",
        "|---|---|---|---|",
    ]
    if not waves:
        lines.append("| — | _(none)_ | — | — |")
    for w in waves:
        lines.append(f"| {w['rank']} | {w['id']} | **{w['delta']}** | proposed |")
    lines += [
        "",
        "## Notes",
        "- Re-run regen after every done wave or new design.",
        "- Continuity restore BLOCKED (App Group).",
        "- Device-pending (passcode) = operator.",
        "",
    ]
    (EVID / "LEDGER.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    done = load_done()
    # persist DONE sorted
    (EVID / "DONE.txt").write_text(
        "# Done WAVE numbers (NNN). Append when compress lands; re-run regen-queue.py.\n"
        + "\n".join(sorted(done))
        + "\n",
        encoding="utf-8",
    )
    waves = open_waves(done)
    write_queue(waves, done)
    write_ledger(waves, done)
    print(f"done={sorted(done)}")
    print(f"open={[(w['rank'], w['delta'], w['id']) for w in waves]}")


if __name__ == "__main__":
    main()
