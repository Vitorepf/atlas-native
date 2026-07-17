import SwiftUI

// Assinatura sussurrada — peel de EditorialTurnChrome (régua ≤100).
// Text → EditorialTurnChrome+SignatureText.swift
// Gate → EditorialTurnChrome+SignatureGate.swift

struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    let reduceMotion: Bool
    @State var shown = false

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
