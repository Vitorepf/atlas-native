import SwiftUI
import AtlasCore

// Corpo com sinal publicado — peel de AutonomosOperationDigestSection.
// Quiet → +Quiet · Meta → +SignalMeta

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AutonomosChrome.sectionCaption("RESUMO DA OPERAÇÃO")
                Spacer()
                Text(incidentPresent ? "requer você" : "por exceção")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(incidentPresent ? AtlasTheme.domOperacional : AtlasTheme.domAutonomos)
                    .accessibilityHidden(true)
            }
            Text(AutonomosOperationDigestA11y.displayHeadline(
                delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            digestSignalMeta
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(incidentPresent ? AtlasTheme.domOperacional.opacity(0.4) : AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosOperationDigestA11y.spokenSection(
            deliveredTotal: deliveredTotal,
            pendingCount: pendingCount,
            inboxCount: inboxCount,
            incidentPresent: incidentPresent,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt,
            findingsByRisk: findingsByRisk
        ))
        .accessibilityIdentifier(A11yID.autonomosOperationDigest)
    }
}
