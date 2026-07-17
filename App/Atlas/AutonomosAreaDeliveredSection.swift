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
}
