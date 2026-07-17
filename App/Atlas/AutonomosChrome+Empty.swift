import SwiftUI
import AtlasCore

/// Card vazio Autônomos — caption + copy editorial (frota, histórico, digest).
/// Fleet copy → AutonomosChrome+FleetEmptyCopy.swift
struct AutonomosCardEmptyState: View {
    let caption: String
    let copy: String
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption(caption, role: .decorative)
            Text(copy)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(caption), \(copy)")
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct AutonomosFleetEmptyState: View {
    enum Kind { case noAgents, noHistory }

    let kind: Kind

    var body: some View {
        AutonomosCardEmptyState(
            caption: kind == .noAgents ? "frota" : "histórico",
            copy: copy,
            accessibilityIdentifier: kind == .noAgents ? A11yID.autonomosFleetEmpty : A11yID.autonomosFleetHistoryEmpty
        )
    }
}
