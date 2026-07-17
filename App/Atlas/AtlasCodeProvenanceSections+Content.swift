import SwiftUI
import AtlasCore

// Conteúdo carregado da folha de proveniência — peel de AtlasCodeProvenanceSections.

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
                if let detail = message.nonEmpty {
                    Text(detail)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(spokenFailed(message))
        case .loaded(let provenance):
            if hasLoadedBody(provenance) {
                VStack(alignment: .leading, spacing: 18) {
                    if let body = provenance.commitBody?.nonEmpty {
                        Text(AtlasCodeCommitBody.prose(body))
                            .font(AtlasFont.serif(15))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier(A11yID.codeCommitBody)
                    }

                    if let quote = provenance.operatorQuote?.nonEmpty {
                        pullQuote(quote)
                    }

                    if let gates = provenance.gates, !gates.isEmpty {
                        block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
                    }
                    if let obra = provenance.obra, !obra.isEmpty {
                        block("Obra") { AtlasCodeChipRow(items: obra) }
                    }

                    filesSection(provenance, whyTarget: whyTarget)
                }
            }
        }
    }

    func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}
