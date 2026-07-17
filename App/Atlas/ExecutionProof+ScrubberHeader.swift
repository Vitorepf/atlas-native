import SwiftUI
import AtlasCore

// Scrubber header — peel de ExecutionProof+ScrubberChrome.
// Meta → ExecutionProof+ScrubberMeta.swift
// Title → ExecutionProof+ScrubberTitle.swift

extension ExecutionProof {
    func replayScrubberHeader(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberTitle(index: index, total: total)
            replayScrubberMeta(selected: selected)
        }
    }
}
