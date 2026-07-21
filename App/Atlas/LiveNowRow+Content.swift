import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de LiveNowRow.
// Remote badge → LiveNowRow+RemoteBadge.swift
// Chevron → LiveNowRow+Chevron.swift
// Title → LiveNowRow+ContentTitle.swift
// RowStack → LiveNowRow+Content+RowStack.swift

extension LiveNowRow {
    var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            rowContentStack(now: context.date)
        }
    }
}
