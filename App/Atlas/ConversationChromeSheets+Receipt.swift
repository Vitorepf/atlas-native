import SwiftUI
import AtlasCore

// Recibo de continuidade — peel de ConversationChromeSheets; selos → +Seals.
// Copy → ConversationChromeSheets+Receipt+Copy.swift

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .symbolEffect(.rotate, isActive: isPending && !reduceMotion)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(headline)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Text(subline)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
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
