import SwiftUI

/// Arena load / domain failure — thin host sobre `AtlasOpsFailureEmpty` (WAVE-008).
/// Domain-unavailable ≠ offline: mode distinto, mesma máquina de layout/retry.
struct ArenaPremiumLoadFailureView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: model.isDomainUnavailable
                ? .domainUnavailable
                : .load(
                    headline: "Não foi possível carregar a medição",
                    message: "A tela não transformou a falha de rede em estado vazio."
                ),
            layout: .leadingEditorial,
            kicker: model.isDomainUnavailable ? "Arena não publicada" : "Arena indisponível",
            symbol: model.isDomainUnavailable ? "shippingbox" : "wifi.exclamationmark",
            topPadding: 0,
            accessibilityIdentifier: A11yID.arenaPremiumState("failed-load"),
            retryHint: "tenta carregar a Arena de novo",
            onRetry: { Task { await model.load() } }
        )
    }
}
