import SwiftUI
import AtlasCore

extension AtlasCodeView {
    @ViewBuilder
    func graphFailure(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(AtlasCodePalette.alert)
            Text("não consegui ler este repositório")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button("Tentar de novo") { Task { await model.load() } }
                .buttonStyle(.borderedProminent)
                .tint(AtlasTheme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
