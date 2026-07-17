import SwiftUI

/// Cabeçalho da área Autônomos — voltar, título, refresh da área selecionada.
/// Title → +Title · Buttons → +Buttons.swift
struct AutonomosViewHeader: View {
    let auditModeEnabled: Bool
    let canRefresh: Bool
    let isHealthy: Bool
    let reduceMotion: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            backButton
            titleBlock
            Spacer()
            refreshButton
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }
}
