import SwiftUI

/// Hero do motor medido: o nome é o seletor (nunca “Trocar motor”).
/// Só lista opções já medidas — catálogo sem perfil não entra.
struct ArenaPremiumEngineTitle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let engineID: String
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if options.count > 1 {
            Menu {
                ForEach(options, id: \.self) { engine in
                    Button {
                        // Soft: engine swap is navigation, not commit.
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onSelect(engine)
                    } label: {
                        if engine == engineID {
                            Label(ArenaDisplay.engine(engine), systemImage: "checkmark")
                        } else {
                            Text(ArenaDisplay.engine(engine))
                        }
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ArenaDisplay.engine(engineID))
                        .font(AtlasFont.serif(33))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Motor medido, \(ArenaDisplay.engine(engineID))")
            .accessibilityHint("Abre a lista dos outros motores medidos")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.arenaPremiumEnginePicker)
        } else {
            Text(ArenaDisplay.engine(engineID))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }
}
