import SwiftUI
import AtlasCore

// Scrubber chrome — peel de ExecutionProof+Scrubber.
// Header → ExecutionProof+ScrubberHeader.swift

extension ExecutionProof {
    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberHeader(index: index, total: total, selected: selected)
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }
}
