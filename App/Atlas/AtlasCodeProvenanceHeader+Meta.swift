import SwiftUI
import AtlasCore

// Dateline / state / hash — peel de AtlasCodeProvenanceHeader.
// Dateline → AtlasCodeProvenanceHeader+Dateline.swift

extension AtlasCodeProvenanceSheet {
    var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel("hash do commit")
    }
}
