import SwiftUI
import AtlasCore

// Now section chrome — peel de ArenaNowSection.
// Live note → ArenaNowSection+LiveNote.swift
// Stack → ArenaNowSection+Stack.swift

extension ArenaNowSection {
    var nowSectionBody: some View {
        nowSectionStack
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ArenaNowSectionA11y.spokenSection(
                running: runningCount,
                queuedSuites: queuedSuiteNames.count
            ))
            .accessibilityIdentifier(A11yID.arenaNowSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
    }
}
