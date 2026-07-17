import SwiftUI
import AtlasCore

// Session rows — peel de LiveNowSection.
// Separator → LiveNowSection+RowSeparator.swift

extension LiveNowSection {
    @ViewBuilder
    var liveNowRows: some View {
        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
            if isHub, index > 0 {
                LiveNowRowSeparator.hub
            }
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
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 8)),
                removal: .opacity
            ))
        }
    }
}
