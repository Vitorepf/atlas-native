import SwiftUI
import AtlasCore

// Recibo de continuidade — peel de ConversationChromeSheets; selos → +Seals.
// Copy → ConversationChromeSheets+Receipt+Copy.swift
// Lead → ConversationChromeSheets+Receipt+Lead.swift

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        HStack(spacing: 9) {
            receiptIcon
            receiptCopy
            Spacer(minLength: 0)
        }
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
