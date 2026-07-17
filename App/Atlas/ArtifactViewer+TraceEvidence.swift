import SwiftUI

/// Copy editorial para `reason` do contrato trace-scoped — nunca inventa motivo.
/// Unavailable → ArtifactViewer+TraceEvidenceUnavailable.swift
enum TraceEvidenceCopy {
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default:
            return reason.replacingOccurrences(of: "_", with: " ")
        }
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }
}

/// Loading compartilhado por ArtifactSheet e ChangeReviewSheet.
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
        .accessibilityLabel(text)
    }
}
