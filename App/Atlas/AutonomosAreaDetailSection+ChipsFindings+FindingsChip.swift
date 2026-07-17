import SwiftUI
import AtlasCore

// Findings chip — peel de AutonomosAreaDetailSection+ChipsFindings.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogFindingsChip(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChipButton(
            label: "findings \(backlog.findings.returned)", kind: .findings,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .findings, count: backlog.findings.returned)
        ) { onOpenDetail(.findings) }
    }
}
