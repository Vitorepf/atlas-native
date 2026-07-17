import SwiftUI

// Assinatura sussurrada — peel de EditorialTurnChrome (régua ≤100).
// Text → EditorialTurnChrome+SignatureText.swift

struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    let reduceMotion: Bool
    @State var shown = false

    /// Modelo ou provider reais — nunca fabrica «atlas» quando o contrato não publica quem respondeu.
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        let hasModel = model.map { !$0.isEmpty && !$0.hasSuffix("_default") } ?? false
        let hasProvider = provider.map { !$0.isEmpty } ?? false
        return hasModel || hasProvider
    }

    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .accessibilityLabel(EditorialTurnA11y.spokenSignature(provider: provider, model: model, elapsedMs: elapsedMs))
            .accessibilityIdentifier(A11yID.editorialTurnSignature)
            .onAppear { revealSignature() }
    }
}
