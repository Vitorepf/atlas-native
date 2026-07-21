import AtlasCore
import Foundation
import SwiftUI

// Cycle 043 fuse → ChangeReviewCouncilRow.swift

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            providerHeader
            metaRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(member.spokenCouncilLine)
        .accessibilityIdentifier(A11yID.reviewCouncilMember(member.provider))
    }
}

/// Só fala o que `council_review` publica; sem `agentVerdicts` nem papéis inventados.

extension AtlasTraceGovernance.CouncilMember {
    var spokenCouncilLine: String {
        var parts = [provider]
        if let model = model { parts.append(model) }
        parts.append("status \(status)")
        if let hash = responseHash {
            parts.append("hash de resposta \(String(hash.prefix(12)))")
        }
        if let code = errorCode { parts.append("código \(code)") }
        if let latency = latencyMs { parts.append("\(latency) milissegundos") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerOutcomeGlyph: some View {
        Image(systemName: member.succeeded ? "checkmark" : "xmark")
            .atlasSans(9, .semibold)
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerHeader: some View {
        HStack(spacing: 7) {
            providerOutcomeGlyph
            Text(member.provider)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            providerModelLabel
            Spacer()
            providerStatus
        }
    }
}

enum ChangeReviewCouncilA11y {
    static func spokenSection(memberCount: Int, diverged: Bool) -> String {
        var parts = ["conselho, \(memberCount) \(memberCount == 1 ? "membro" : "membros")"]
        if diverged { parts.append("divergência entre pareceres") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var providerModelLabel: some View {
        if let model = member.model {
            Text(model)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerStatus: some View {
        Text(member.status)
            .font(AtlasFont.mono(9))
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaRow: some View {
        HStack(spacing: 8) {
            metaHashCode
            metaLatency
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaHashCode: some View {
        if let hash = member.responseHash {
            Text("hash \(String(hash.prefix(12)))")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        if let code = member.errorCode {
            Text(code)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaLatency: some View {
        if let latency = member.latencyMs {
            Text("\(latency)ms")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
