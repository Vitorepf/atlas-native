import SwiftUI
import AtlasCore

/// Card vazio Autônomos — caption + copy editorial (frota, histórico, digest).
/// Fleet → AutonomosChrome+FleetEmpty.swift
/// Fleet copy → AutonomosChrome+FleetEmptyCopy.swift
/// Chrome → AutonomosChrome+EmptyChrome.swift

struct AutonomosCardEmptyState: View {
    let caption: String
    let copy: String
    let accessibilityIdentifier: String

    var body: some View {
        emptyCardChrome(
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption(caption, role: .decorative)
                Text(copy)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
        )
    }
}
