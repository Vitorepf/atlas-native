import SwiftUI
import AtlasCore

// WAVE-009 fused Provenance sections
// Single-feature peel fusion for Code depth instrument.

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
        .accessibilityLabel(AtlasCodeAskPillJudgment.askCommitLabel)
        .accessibilityHint(Self.askHint)
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
        .atlasCard(cornerRadius: AtlasTheme.Radius.control)
        .contentShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
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

