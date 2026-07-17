import SwiftUI
import AtlasCore

// Choice button label — peel de ExecutionStateCard+ActionChoicesStack.

extension ExecutionStateCard {
    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button { onChoose(choiceJobId, action.id) } label: {
            Text(action.title)
                .font(.system(.caption, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
    }
}
