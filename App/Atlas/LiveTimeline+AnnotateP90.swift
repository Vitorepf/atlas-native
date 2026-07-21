import SwiftUI
import AtlasCore

// P90 threshold annotation — peel de LiveTimeline+AnnotateDurations.

func annotateNarrativeP90(_ rows: inout [NarrativeRow]) {
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}
