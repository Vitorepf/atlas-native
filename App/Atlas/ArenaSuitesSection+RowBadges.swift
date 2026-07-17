import SwiftUI
import AtlasCore

// Suite leading badges — peel de ArenaSuitesSection+RowLeading.
// Title → ArenaSuitesSection+RowBadges+Title.swift
// Regression → ArenaSuitesSection+RowBadges+Regression.swift

extension ArenaSuiteRow {
    var suiteLeadingBadges: some View {
        HStack(spacing: 8) {
            suiteTitleBadges
            suiteRegressionBadge
        }
    }
}
