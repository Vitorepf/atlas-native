import SwiftUI

/// Folha Novo Autônomo — nome + carta (mockup v9).
struct AutonomosNewSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name = ""
    @State private var charter = ""
    let onCreate: (String, String) -> Void
    let onCancel: () -> Void

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AutonomosMapChrome.heroTitle("Novo Autônomo", size: 28)
                    Text("Um escopo fechado. Fica neste iPhone até o create no servidor existir.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    field(
                        label: "Nome",
                        placeholder: "ex.: Agente iOS Dinheiro",
                        text: $name,
                        axis: .horizontal
                    )
                    field(
                        label: "Carta",
                        placeholder: "O que este Autônomo pode e não pode tocar.",
                        text: $charter,
                        axis: .vertical
                    )

                    AutonomosMapChrome.primaryCTA("Guardar neste iPhone", enabled: canCreate) {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onCreate(name, charter)
                    }
                    Text("Não publica frota no servidor. Some se o app for morto.")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    AutonomosMapChrome.quietCTA("Cancelar", action: onCancel)
                }
                .padding(AtlasTheme.Space.screen)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            Group {
                if axis == .vertical {
                    TextField(placeholder, text: text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(AtlasFont.serif(17))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AtlasTheme.bgRecessed, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .strokeBorder(AtlasTheme.separator.opacity(0.55), lineWidth: 1)
            )
        }
    }
}
