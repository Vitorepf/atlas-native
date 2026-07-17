import SwiftUI
import AtlasCore

// Now run row content — peel de ArenaNowSection+Rows.
// Copy → ArenaNowSection+RowCopy.swift

extension ArenaNowSection {
    func nowRunRow(_ run: AtlasArenaLiveRun) -> some View {
        HStack(spacing: 10) {
            statusIndicator(for: run)
            nowRunCopy(run)
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
