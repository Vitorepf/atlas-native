import SwiftUI

/// Aviso de integridade do diff — só quando o servidor publica `hashMatches == false`.
struct ChangeReviewHashWarning: View {
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("atenção: o hash do diff não confere com o artefato registrado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("atenção: o hash do diff não confere com o artefato registrado")
        .accessibilityIdentifier(A11yID.reviewHashWarning)
    }
}
