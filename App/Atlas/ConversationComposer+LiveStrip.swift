import SwiftUI
import AtlasCore

// Live instrument host no composer — WAVE-006. Thin wrapper → ExecutingStrip.

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSection: some View {
        if let live = liveBubble {
            ExecutingStrip(
                bubble: live,
                reduceMotion: reduceMotion,
                onStop: { model.cancel() },
                onSteer: live.traceId.map { trace in { steerTrace = ConversationSteerTraceRef(id: trace) } }
            )
            .padding(.top, expanded ? 0 : 4)
            .padding(.bottom, expanded ? 0 : 8)
            .transition(.opacity)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                .padding(.bottom, expanded ? 0 : 8)
                .accessibilityHidden(true)
        }
    }
}
