import SwiftUI
import AtlasCore

// ExecutingStrip — peel de ConversationCockpit (régua ≤110).
// Status → ConversationCockpit+ExecutingStrip+Status.swift

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
    }
}
