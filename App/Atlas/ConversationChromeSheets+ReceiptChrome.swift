import SwiftUI
import AtlasCore

// Receipt chrome padding — peel de ConversationChromeSheets+Receipt.

extension ConversationHandoffReceipt {
    func receiptChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
    }
}
