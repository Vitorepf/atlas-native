import SwiftUI
import AtlasCore

// Empty → AutonomosDetailSheet+Empty.swift
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
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let backlog {
                        AutonomosDetailContent.rows(kind: kind, backlog: backlog)
                            .transition(reduceMotion ? .identity : .opacity)
                    } else {
                        emptyProjection
                    }
                }
                .padding(AtlasTheme.Space.screen)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(kind.title)
            .toolbar { detailToolbar }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .accessibilityIdentifier(A11yID.autonomosDetailSheet)
        .accessibilityLabel(spokenSheetLabel(backlog: backlog))
        .accessibilityHint(spokenSheetHint())
    }
}
