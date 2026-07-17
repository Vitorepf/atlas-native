import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de LiveNowRow.
// Remote badge → LiveNowRow+RemoteBadge.swift
// Chevron → LiveNowRow+Chevron.swift
// Title → LiveNowRow+ContentTitle.swift

extension LiveNowRow {
    var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                BreathingDiamond(
                    size: 8,
                    reduceMotion: reduceMotion || session.timing != .running
                )
                rowTitleStack(now: context.date)
                Spacer(minLength: 0)
                rowChevron
            }
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }
}
