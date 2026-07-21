import SwiftUI

// Banner mono de execução — peel de ConversationCockpit+Agents (CICLO C).
// Chrome → ConversationCockpit+ExecutionBannerChrome.swift

struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
        bannerChrome
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(embedInParent)
            .accessibilityLabel(ExecutionBannerA11y.spoken(text: text))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}
