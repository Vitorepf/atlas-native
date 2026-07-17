import SwiftUI
import AtlasCore

// Delivered row + helpers — peel de AutonomosAreaDeliveredSection.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredCycleRow(cycle: AtlasAutonomosCycle, index: Int, visible: Int, isSelf: Bool) -> some View {
        if isSelf {
            Button {
                onSelfConstructionReceipt(SelfConstructionReceipt(cycle: cycle, finding: selfConstructionFinding))
            } label: {
                deliveredRow(cycle)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: true, opensGraph: false))
            .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: true))
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        } else if let repo = area.repositoryNames.first?.nonEmpty {
            Button {
                openCommit(cycle.mergeHash, repo: repo)
            } label: {
                deliveredRow(cycle, graphHint: true)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: false, opensGraph: true))
            .accessibilityHint(AutonomosAreaDeliveredA11y.spokenRowHint(isSelf: false))
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        } else {
            deliveredRow(cycle)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenRow(cycle, index: index, visible: visible, isSelf: false, opensGraph: false))
                .accessibilityIdentifier(A11yID.autonomosAreaDeliveredRow(index))
        }
    }

    func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
            Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            if graphHint {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
            Spacer()
            Text(cycle.recordedAt).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    func openCommit(_ hash: String, repo: String) {
        guard let url = URL(string: "atlas://code/\(repo)?commit=\(hash)") else { return }
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        openURL(url)
    }

    func isSelfConstructionArea(_ area: AtlasAutonomosArea) -> Bool {
        area.repositoryNames.contains("atlas-native")
    }

    var selfConstructionFinding: AtlasAutonomosFinding? {
        model.backlog?.findings.items.first {
            $0.source == "native_constitution_scan"
                && (($0.ruleId?.isEmpty == false) || ($0.ruleText?.isEmpty == false))
        }
    }
}
