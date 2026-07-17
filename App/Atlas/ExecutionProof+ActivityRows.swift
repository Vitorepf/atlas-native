import SwiftUI
import AtlasCore

// Activity rows — peel de ExecutionProof+Expanded.
// Copy → ExecutionProof+ActivityRowCopy.swift

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: activityIcon(act.kind))
                        .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                        .frame(width: 15)
                        .accessibilityHidden(true)
                    activityRowCopy(act)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
                )
            }
        }
    }
}
