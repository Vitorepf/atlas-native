import SwiftUI
import AtlasCore

// Folha da missão noturna — peel de AutonomosSheetsModifier.
// Accept → AutonomosSheetsModifier+NightlyAccept.swift
// Start → AutonomosSheetsModifier+NightlyStart.swift
// Reason → AutonomosSheetsModifier+NightlyReason.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func nightlyStartSheet(on content: some View) -> some View {
        content
            .sheet(item: $nightlyStartProposal) { proposal in
                nightlyReasonSheet(for: proposal)
            }
    }
}
