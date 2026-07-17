import SwiftUI
import AtlasCore

// Title / phase stack — peel de LiveNowRow+Content.
// Phase → LiveNowRow+ContentPhase.swift
// Title → LiveNowRow+ContentTitleText.swift

extension LiveNowRow {
    func rowTitleStack(now: Date) -> some View {
        VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
            rowTitleText
            rowPhaseLine
            // Timing explícito (running/paused) + elapsed.
            timingLine(now: now)
        }
    }
}
