import SwiftUI
import AtlasCore

/// Linha silenciosa de disclosure dos resumos — o card completo só ocupa a
/// tela quando o operador pede. Mono, terciária, chevron que gira.
struct AutonomosDigestToggleLine: View {
    let title: String
    let detail: String
    @Binding var expanded: Bool
    var a11yID: String = ""
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button {
            if reduceMotion { expanded.toggle() } else {
                withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() }
            }
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(AtlasFont.mono(10, .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text(detail)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .rotationEffect(.degrees(expanded ? 180 : 0))
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title): \(detail)")
        .accessibilityHint(expanded ? "toque para recolher o resumo" : "toque para abrir o resumo completo")
        .accessibilityIdentifier(a11yID)
    }
}
