import SwiftUI

struct ArenaPremiumLoadFailureView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumEmptyGlyph(
                symbol: model.isDomainUnavailable ? "shippingbox" : "wifi.exclamationmark",
                tone: .neutral
            )
            ArenaPremiumKicker(text: model.isDomainUnavailable ? "Arena não publicada" : "Arena indisponível")
            Text(model.isDomainUnavailable ? "A medição ainda não existe neste servidor" : "Não foi possível carregar a medição")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(
                model.isDomainUnavailable
                    ? "Nenhum índice, progresso ou resultado foi presumido."
                    : "A tela não transformou a falha de rede em estado vazio."
            )
            .font(AtlasFont.serifItalic(16))
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            ArenaPremiumAction(title: "Tentar novamente", symbol: "arrow.clockwise") {
                Task { await model.load() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
        .accessibilityIdentifier(A11yID.arenaPremiumState("failed-load"))
    }
}
