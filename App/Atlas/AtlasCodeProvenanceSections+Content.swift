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
                Text("não consegui ler a proveniência")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text(message)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.alert)
            }
        case .loaded(let provenance):
            VStack(alignment: .leading, spacing: 18) {
                if let body = provenance.commitBody {
                    Text(AtlasCodeCommitBody.prose(body))
                        .font(AtlasFont.serif(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier(A11yID.codeCommitBody)
                }

                if let quote = provenance.operatorQuote {
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

    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
            VStack(alignment: .leading, spacing: 5) {
                Text("\u{201C}\(quote)\u{201D}")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("sua frase")
                    .font(.system(size: 9))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }

    /// O que o commit tocou — no fim, onde o olho procura depois de entender.
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("ARQUIVOS")
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityIdentifier(A11yID.codeCommitFiles)

            if provenance.files.isEmpty {
                Text("nenhum arquivo mudou neste commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                        if index > 0 {
                            Divider().overlay(AtlasTheme.separator.opacity(0.5))
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            whyTarget.wrappedValue = AtlasCodeProvenanceWhyTarget(path: file.path)
                        } label: {
                            AtlasCodeFileRow(file: file, accessibilityIdentifier: A11yID.whyFileRow(index))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(A11yID.whyFileRow(index))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
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
