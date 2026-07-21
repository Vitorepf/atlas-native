import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: TraceEvidenceChrome fused

// MARK: - TraceEvidenceChrome

enum TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownMissingRunReason(reason)
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownUnavailableReason(reason)
    }

    static func unavailableReason(_ reason: String?) -> String? {
        TraceEvidenceJudgment.unavailableReason(reason)
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        TraceEvidenceJudgment.spokenUnavailable(prefix: prefix, reason: reason)
    }
}

struct TraceEvidenceLoading: View {
    let text: String
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 12) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(TraceEvidenceJudgment.spokenLoading(text))
        .accessibilityValue(TraceEvidenceFace.loading.productWord)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableIconTitle: some View {
        Image(systemName: systemImage)
            .font(.title2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .multilineTextAlignment(.center)
            .accessibilityHidden(true)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableSubtitle: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityValue(TraceEvidenceFace.unavailable.productWord)
            .accessibilityIdentifier(identifier)
    }
}

