import SwiftUI
import AtlasCore

// Now run copy — peel de ArenaNowSection+RowContent.

extension ArenaNowSection {
    func nowRunCopy(_ run: AtlasArenaLiveRun) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(ArenaDisplay.suite(run.suite)) · \(ArenaDisplay.engine(run.engineDisplayName))")
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
            Text(
                [ArenaDisplay.origin(run.origin), run.arm?.labelPT ?? "braço desconhecido", run.progressText]
                    .compactMap(\.self)
                    .joined(separator: " · ")
            )
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityHidden(true)
    }
}
