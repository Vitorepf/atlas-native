import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → ChangeReviewFindingRow+Body.swift

extension ChangeReviewFindingRow {
    var findingBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(Self.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(.footnote).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            findingPathAndRecommendation
        }
        .padding(.vertical, 3)
    }
}

extension ChangeReviewFindingRow {
    static func severitySpokenHigh(_ s: String) -> String? {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        default: return nil
        }
    }
}

extension ChangeReviewFindingRow {
    static func severitySpoken(_ s: String) -> String {
        if let high = severitySpokenHigh(s) { return high }
        switch s.lowercased() {
        case "medium": return "média"
        case "low": return "baixa"
        default: return s
        }
    }
}
