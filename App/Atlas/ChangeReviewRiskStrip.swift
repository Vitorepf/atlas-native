import AtlasCore
import SwiftUI

// MARK: - Risk face strip (WAVE-039)

/// Thin chrome: exclusive risk face for Revisar mudanças.
struct ChangeReviewRiskStrip: View {
    let review: AtlasTraceChangeReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: ChangeReviewRiskFace {
        ChangeReviewJudgment.face(from: review)
    }

    var body: some View {
        switch face {
        case .empty:
            EmptyView()
        case .quiet, .elevated, .critical:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(titleColor)
                Text(ChangeReviewJudgment.summaryLine(from: review))
                    .font(AtlasFont.serif(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .fill(AtlasTheme.surface.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace + ", " + ChangeReviewJudgment.summaryLine(from: review))
        .accessibilityIdentifier(A11yID.reviewRiskFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet: return AtlasTheme.textTertiary
        case .empty: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet, .empty: return AtlasTheme.textTertiary
        }
    }

    private var borderColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional.opacity(0.35)
        case .elevated: return AtlasTheme.accent.opacity(0.28)
        case .quiet, .empty: return AtlasTheme.separatorSoft
        }
    }
}
