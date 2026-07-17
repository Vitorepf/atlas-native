import SwiftUI
import AtlasCore

// Empty → AutonomosDetailSheet+Empty.swift
// Scroll → AutonomosDetailSheet+Scroll.swift
// Presentation → AutonomosDetailSheet+Presentation.swift
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
        detailPresentation
    }
}
