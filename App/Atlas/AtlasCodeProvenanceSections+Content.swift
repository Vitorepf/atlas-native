import SwiftUI
import AtlasCore

// Conteúdo carregado da folha de proveniência — peel de AtlasCodeProvenanceSections.
// Loaded → AtlasCodeProvenanceSections+Loaded.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
                .padding(.top, 2)
        case .failed(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text("proveniência indisponível")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
                if let detail = message.nonEmpty {
                    Text(detail)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed(message))
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}
