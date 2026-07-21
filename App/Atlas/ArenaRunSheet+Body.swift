import SwiftUI
import AtlasCore

// Run form scroll — peel de ArenaRunSheet.

extension ArenaRunSheet {
    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    ArenaPremiumKicker(text: "Nova medição", tone: .active)
                    Text("O que vamos medir?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("Escolha somente o necessário. A ordem e o progresso aparecem na Arena assim que o servidor confirmar.")
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                formSections
                planPreview
                statusBlocks
                submitButton
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Rodar medição")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { runToolbar }
    }

    @ViewBuilder
    private var planPreview: some View {
        if !selectedSuites.isEmpty, !selectedEngines.isEmpty, !selectedArms.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ArenaPremiumKicker(text: "Plano")
                Text(
                    "\(selectedEngines.count) \(selectedEngines.count == 1 ? "motor" : "motores") · "
                        + "\(selectedSuites.count) \(selectedSuites.count == 1 ? "suíte" : "suítes") · "
                        + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas"
                )
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                Text(selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: " → "))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.vertical, 4)
        }
    }
}
