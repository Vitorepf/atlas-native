import SwiftUI
import AtlasCore

// Run header fields — peel de ChangeReviewSections.
// Title → ChangeReviewSections+RunFields+TitleStack.swift
// Score → ChangeReviewSections+RunFields+Score.swift

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }
}
