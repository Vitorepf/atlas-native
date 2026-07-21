import AtlasCore
import SwiftUI

// Cycle 038 fuse → AtlasCodeProvenanceSections+Failed.swift

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
