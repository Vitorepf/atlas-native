import SwiftUI
import AtlasCore

// Spine da narrativa — peel de LiveTimeline+NarrativeBody.

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}
