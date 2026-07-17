import SwiftUI
import AtlasCore

// Entregas comprovadas — peel de AutonomosAreaDetailSection.

struct AutonomosAreaDeliveredSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        deliveredSection
    }

    /// C13 + Elite C: merge comprovado = sucesso/silêncio; delivered_total=0
    /// em auto-construção = vazio honesto (nunca “melhorou” sem ledger).
    @ViewBuilder
    private var deliveredSection: some View {
        let isSelf = isSelfConstructionArea(area)
        let deliveredTotal = model.delivered?.deliveredTotal ?? 0
        if let delivered = model.delivered, deliveredTotal > 0 {
            VStack(alignment: .leading, spacing: 6) {
                Text(isSelf ? "O ATLAS MELHOROU O PRÓPRIO APP" : "ENTREGAS COMPROVADAS · \(delivered.deliveredTotal)")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(isSelf ? AtlasTheme.domAutonomos : AtlasTheme.accent)
                if isSelf {
                    Text("silêncio · você não foi necessário — só veto com recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(delivered.delivered.prefix(3)) { cycle in
                    if isSelf {
                        Button {
                            onSelfConstructionReceipt(SelfConstructionReceipt(
                                cycle: cycle,
                                finding: selfConstructionFinding
                            ))
                        } label: {
                            deliveredRow(cycle)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("recibo de auto-construção, ciclo \(cycle.cycleIndex), merge \(String(cycle.mergeHash.prefix(8)))")
                    } else {
                        if let repo = area.repositoryNames.first?.nonEmpty {
                            Button {
                                openCommit(cycle.mergeHash, repo: repo)
                            } label: {
                                deliveredRow(cycle, graphHint: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("abrir merge \(String(cycle.mergeHash.prefix(8))) no grafo de \(repo)")
                        } else {
                            deliveredRow(cycle)
                        }
                    }
                }
            }
        } else if isSelf {
            VStack(alignment: .leading, spacing: 6) {
                Text("AUTO-CONSTRUÇÃO")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text("Trabalho ainda não mergeado — aguardando o ledger. Sem entrega comprovada neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityLabel("auto-construção, aguardando ledger, nenhuma entrega comprovada")
        }
    }

    private func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
            Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            if graphHint {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Spacer()
            Text(cycle.recordedAt).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    private func openCommit(_ hash: String, repo: String) {
        guard let url = URL(string: "atlas://code/\(repo)?commit=\(hash)") else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        openURL(url)
    }

    private func isSelfConstructionArea(_ area: AtlasAutonomosArea) -> Bool {
        area.repositoryNames.contains("atlas-native")
    }

    private var selfConstructionFinding: AtlasAutonomosFinding? {
        model.backlog?.findings.items.first {
            $0.source == "native_constitution_scan"
                && (($0.ruleId?.isEmpty == false) || ($0.ruleText?.isEmpty == false))
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
