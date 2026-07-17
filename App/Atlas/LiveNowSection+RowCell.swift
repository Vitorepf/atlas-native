import SwiftUI
import AtlasCore

// LiveNow row cell — peel de LiveNowSection+Rows.
// Transition → LiveNowSection+RowCell+Transition.swift

extension LiveNowSection {
    func liveNowRowCell(index: Int, session: LiveSessionSnapshot) -> some View {
        liveNowRowTransition(
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
        )
    }
}
