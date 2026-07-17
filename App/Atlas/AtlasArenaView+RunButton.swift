import SwiftUI
import AtlasCore

// Botão Rodar medição — peel de AtlasArenaView+Content.

extension AtlasArenaView {
    var runMeasurementButton: some View {
        Button {
            showingRunSheet = true
        } label: {
            Label("Rodar medição", systemImage: "play.fill")
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .foregroundStyle(AtlasTheme.accent)
        .accessibilityLabel(runButtonSpoken)
        .accessibilityHint(runButtonHint)
        .accessibilityIdentifier(A11yID.arenaRunButton)
    }
}
