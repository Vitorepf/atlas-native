import Foundation
import SwiftUI

// MARK: - Types

/// Exclusive trace evidence chrome face (WAVE-068).
enum TraceEvidenceFace: Equatable {
    case loading
    case unavailable

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "consultando evidência"
        case .unavailable: return "evidência indisponível"
        }
    }
}

// MARK: - Judgment

/// Pure trace-evidence grammar — face · reason · spoken · pack.
enum TraceEvidenceJudgment {

    static func face(isLoading: Bool) -> TraceEvidenceFace {
        isLoading ? .loading : .unavailable
    }

    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }

    /// Honesty: known codes → PT; else underscore→space; nil if empty.
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func spokenUnavailable(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }

    static func spokenLoading(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? TraceEvidenceFace.loading.spokenFace : trimmed
    }

    static func packFacts(
        isLoading: Bool,
        reason: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isLoading: isLoading)
        facts.append("trace_evidence_face: \(face.productWord)")
        if isLoading {
            absences.append("evidência ainda consultando")
        } else {
            absences.append("evidência indisponível neste recorte")
            if let reason, !reason.isEmpty {
                facts.append("trace_evidence_reason: \(reason)")
                if let spoken = unavailableReason(reason) {
                    facts.append("trace_evidence_reason_pt: \(spoken)")
                }
            }
        }
        return (facts, absences)
    }
}

// MARK: - Chrome

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
