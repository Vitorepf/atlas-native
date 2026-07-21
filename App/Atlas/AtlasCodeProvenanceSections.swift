import AtlasCore
import SwiftUI

// Cycle 044 fuse → AtlasCodeProvenanceSections.swift

// MARK: - Seções da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        lawCitationChrome
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelLead: some View {
        Text("✦")
            .font(AtlasFont.serif(12))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
        Text("perguntar sobre este commit")
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelTrailing: some View {
        Spacer(minLength: 0)
        Image(systemName: "arrow.up.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    var askButtonLabel: some View {
        HStack(spacing: 8) {
            askButtonLabelLead
            askButtonLabelTrailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(minHeight: 48)
        .atlasCard(cornerRadius: AtlasTheme.Radius.control)
        .contentShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedDetail(_ message: String) -> some View {
        if let detail = message.nonEmpty {
            Text(detail)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedA11y<Content: View>(_ content: Content, message: String) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed(message))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedBody(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedStack(_ message: String) -> some View {
        provenanceFailedA11y(provenanceFailedBody(message), message: message)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var provenanceFailedTitle: some View {
        Text("proveniência indisponível")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        provenanceFailedStack(message)
    }
}

extension AtlasCodeProvenanceSheet {
    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAsk()
        } label: {
            askButtonLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel("perguntar ao Atlas sobre este commit")
        .accessibilityHint(Self.askHint)
    }
}

extension AtlasCodeProvenanceSheet {
    func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .atlasSans(8.5, .semibold)
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
            .padding(.top, 2)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            provenanceLoadingContent
        case .failed(let message):
            provenanceFailed(message)
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFileButton(
        _ file: AtlasCodeFileChange,
        index: Int,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            whyTarget.wrappedValue = AtlasCodeProvenanceWhyTarget(path: file.path)
        } label: {
            AtlasCodeFileRow(file: file, accessibilityIdentifier: A11yID.whyFileRow(index))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.whyFileRow(index))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            filesSectionBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func filesSectionBody(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            filesSectionHeader
            provenanceFilesList(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var filesSectionHeader: some View {
        Text("ARQUIVOS")
            .atlasSans(8.5, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(A11yID.codeCommitFiles)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFilesList(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                if index > 0 {
                    Divider().overlay(AtlasTheme.separator.opacity(0.5))
                }
                provenanceFileButton(file, index: index, whyTarget: whyTarget)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCanonText(_ ruleCanon: String) -> some View {
        Text(ruleCanon)
            .font(AtlasFont.mono(8.5))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
            .lineLimit(1)
            .truncationMode(.head)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawRuleText(_ ruleId: String) -> some View {
        Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
            .font(AtlasFont.serif(14, .semibold))
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCitationBody(ruleId: String) -> some View {
        lawCitationChrome(
            VStack(alignment: .leading, spacing: 3) {
                lawRuleText(ruleId)
                if let ruleCanon = ruleCanon?.nonEmpty {
                    lawCanonText(ruleCanon)
                }
            }
        )
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var lawCitationChrome: some View {
        if state == .violating, let ruleId, spokenLawCitation() != nil {
            lawCitationBody(ruleId: ruleId)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func lawCitationChrome<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLawCitation() ?? "")
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceGatesObra(_ provenance: AtlasCodeProvenance) -> some View {
        if let gates = provenance.gates, !gates.isEmpty {
            block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
        }
        if let obra = provenance.obra, !obra.isEmpty {
            block("Obra") { AtlasCodeChipRow(items: obra) }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceLoadedBody(_ provenance: AtlasCodeProvenance, whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        if hasLoadedBody(provenance) {
            VStack(alignment: .leading, spacing: 18) {
                provenanceProseBlocks(provenance)
                provenanceGatesObra(provenance)
                filesSection(provenance, whyTarget: whyTarget)
            }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceProseBlocks(_ provenance: AtlasCodeProvenance) -> some View {
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
    }
}

extension AtlasCodeProvenanceSheet {
    var pullQuoteBar: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.55))
            .frame(width: 2)
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuoteStack(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("sua frase")
                .atlasSans(9)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            pullQuoteBar
            pullQuoteStack(quote)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }
}
