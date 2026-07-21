import SwiftUI
import AtlasCore

// Timing HStack — peel de LiveNowRow+TimingLine.
// Word → LiveNowRow+TimingLine+Stack+Word.swift
// Segments → LiveNowRow+TimingLine+Stack+Segments.swift

extension LiveNowRow {
    func timingLineStack(now: Date) -> some View {
        HStack(spacing: 6) {
            timingLineWordLabel
            timingLineSegments(now: now)
        }
    }
}
