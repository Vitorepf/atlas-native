import SwiftUI
import AtlasCore

// MARK: - Governance / Conselho (C18 · C19 · C21)
// Extraído de ChangeReviewSections sem mudança de comportamento.

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    var body: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)

            if stats != nil || !revisions.isEmpty || !council.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if let stats {
                        HStack(spacing: 8) {
                            Image(systemName: "plusminus")
                                .font(.system(size: 11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            Text(stats.headline)
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .accessibilityLabel("\(stats.filesTouched) arquivos, mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
                        }
                    }

                    if let last = revisions.last {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            Text(revisions.count == 1
                                 ? "plano v1 arquivado — \(last.humanReason)"
                                 : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                                .font(.system(size: 12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                        }
                    }

                    if !council.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Conselho")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                if AtlasTraceGovernance.councilDiverged(council) {
                                    // Divergência é FATO (status/hash distinto),
                                    // não veredito inventado pela casca.
                                    Text("divergência")
                                        .font(AtlasFont.mono(9))
                                        .foregroundStyle(AtlasTheme.accent)
                                }
                            }
                            ForEach(council) { member in
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 7) {
                                        Image(systemName: member.succeeded ? "checkmark" : "xmark")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                                        Text(member.provider)
                                            .font(AtlasFont.mono(10))
                                            .foregroundStyle(AtlasTheme.textSecondary)
                                        if let model = member.model {
                                            Text(model)
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Text(member.status)
                                            .font(AtlasFont.mono(9))
                                            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                                    }
                                    HStack(spacing: 8) {
                                        if let hash = member.responseHash {
                                            Text("hash \(String(hash.prefix(12)))")
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                        }
                                        if let code = member.errorCode {
                                            Text(code)
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(Color(hex: 0xE08C8C))
                                        }
                                        if let latency = member.latencyMs {
                                            Text("\(latency)ms")
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier(A11yID.reviewGovernance)
            }
        }
    }
}
