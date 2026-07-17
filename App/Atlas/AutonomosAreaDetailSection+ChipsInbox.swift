import SwiftUI
import AtlasCore

// Inbox chip — peel de AutonomosAreaDetailSection+ShortcutChips.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    func backlogInboxChip(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChipButton(
            label: "inbox \(backlog.inboxItems.count)", kind: .inbox,
            spokenLabel: AutonomosAreaDetailA11y.spokenChip(kind: .inbox, count: backlog.inboxItems.count)
        ) { onOpenDetail(.inbox) }
    }
}
