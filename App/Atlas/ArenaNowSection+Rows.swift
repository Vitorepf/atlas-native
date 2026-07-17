import SwiftUI
import AtlasCore

// Run rows — peel de ArenaNowSection.

extension ArenaNowSection {
    @ViewBuilder
    var nowRunRows: some View {
        ForEach(runs) { run in
            HStack(spacing: 10) {
                statusIndicator(for: run)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(run.suite) · \(run.engineDisplayName)")
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(1)
                    Text("\(run.arm?.labelPT ?? "braço desconhecido") · \(run.progressText)")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .accessibilityHidden(true)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(ArenaNowSectionA11y.spokenRun(run))
            .accessibilityIdentifier(A11yID.arenaNowRun(run.runIdPublic))
            .transition(reduceMotion ? .identity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
        }
    }
}
