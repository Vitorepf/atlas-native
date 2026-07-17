import SwiftUI
import AtlasCore

// Row HStack — peel de LiveNowRow+Content.
// Leading → LiveNowRow+Content+RowStack+Leading.swift
// Trailing → LiveNowRow+Content+RowStack+Trailing.swift

extension LiveNowRow {
    func rowContentStack(now: Date) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            rowContentLeading(now: now)
            rowContentTrailing
        }
        .opacity(isLongPaused(now: now) ? 0.58 : 1)
    }
}
