import SwiftUI
import AtlasCore

// MARK: - Seções da folha de proveniência (C23)
// Extraídas sem mudança de comportamento — a folha só compõe.

struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        if state == .violating, let ruleId {
            VStack(alignment: .leading, spacing: 3) {
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasCodePalette.alert)
                if let ruleCanon {
                    Text(ruleCanon)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
        }
    }

    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button(action: onAsk) {
            HStack(spacing: 8) {
                Text("✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.accent)
                Text("perguntar sobre este commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .atlasCard(cornerRadius: 12)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel("Perguntar ao Atlas sobre este commit")
    }

    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo o ledger…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
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
