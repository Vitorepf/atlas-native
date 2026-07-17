import SwiftUI
import AtlasCore

// LiveNowRow build — peel de LiveNowSection+RowCell.

extension LiveNowSection {
    func liveNowRowBuild(index: Int, session: LiveSessionSnapshot) -> some View {
        LiveNowRow(
            session: session,
            hubMode: isHub,
            hubIndex: isHub ? index : nil,
            hubCount: isHub ? sessions.count : nil,
            reduceMotion: reduceMotion,
            remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
        ) {
            guard let threadId = session.threadId else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onOpen(threadId, session.title)
        }
        .accessibilityIdentifier(A11yID.liveNowRow(index))
    }
}
