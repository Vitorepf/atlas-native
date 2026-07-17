import SwiftUI
import AtlasCore

// Empty → AutonomosDetailSheet+Empty.swift
// Scroll → AutonomosDetailSheet+Scroll.swift
struct AutonomosPublicDetailSheet: View {
    let kind: AutonomosDetailSheet
    let backlog: AtlasAutonomosBacklogResponse?
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var contentPhaseID: String {
        guard let backlog else { return "unavailable" }
        return "\(kind.id)-\(AutonomosPublicDetailSheet.publicItemCount(kind: kind, backlog: backlog))"
    }

    var body: some View {
        NavigationStack {
            detailScrollBody
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .accessibilityIdentifier(A11yID.autonomosDetailSheet)
        .accessibilityLabel(spokenSheetLabel(backlog: backlog))
        .accessibilityHint(spokenSheetHint())
    }
}
