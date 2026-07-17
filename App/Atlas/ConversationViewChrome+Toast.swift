import SwiftUI
import UIKit
import AtlasCore

// Toast — peel de ConversationViewChrome.
// Edit/copy → ConversationViewChrome+EditCopy.swift
// Handoff → ConversationViewChrome+Handoff.swift

extension ConversationView {
    @ViewBuilder var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.conversationToast)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    clearToast()
                }
        }
    }
}
