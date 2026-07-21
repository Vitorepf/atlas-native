import SwiftUI

// Feedback dirigido — peel de EditorialTurnChrome (régua ≤100).
// Helpers → EditorialTurnChrome+Helpers.swift
// Chip → EditorialTurnChrome+FeedbackChip.swift

struct FeedbackRow: View {
    let active: String?
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                feedbackChip(kind)
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}
