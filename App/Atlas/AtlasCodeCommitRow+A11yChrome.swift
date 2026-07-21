import SwiftUI
import AtlasCore

// Commit row a11y chrome — peel de AtlasCodeCommitRow.
// Tap = proveniência · long press = why · swipe = âncora na pílula (não modal).

extension AtlasCodeCommitRow {
    var commitRowA11yChrome: some View {
        CommitRowAskChrome(
            isDimmed: isDimmed,
            reduceMotion: reduceMotion,
            label: { commitRowLabel },
            accessibilityLabel: AtlasCodeCommitRowA11y.spokenCommitRow(
                node: node, state: state, trunk: trunk, ruleId: ruleId, isDimmed: isDimmed
            ),
            accessibilityHint: commitAccessibilityHint,
            accessibilityID: A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))),
            onTap: onTap,
            onLongPress: commitLongPress,
            onAsk: onAsk
        )
    }
}

private struct CommitRowAskChrome<Label: View>: View {
    let isDimmed: Bool
    let reduceMotion: Bool
    @ViewBuilder let label: () -> Label
    let accessibilityLabel: String
    let accessibilityHint: String
    let accessibilityID: String
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onAsk: (() -> Void)?

    @State private var offset: CGFloat = 0
    /// Evita que o fim do swipe dispare o Button (proveniência).
    @State private var suppressTap = false

    var body: some View {
        Button {
            guard !suppressTap else { return }
            onTap()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .offset(x: offset)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityIdentifier(accessibilityID)
        .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)
        .simultaneousGesture(askDrag)
    }

    private var askDrag: some Gesture {
        DragGesture(minimumDistance: 28)
            .onChanged { value in
                guard onAsk != nil else { return }
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > abs(dy), dx < 0 else { return }
                offset = max(dx, -72)
            }
            .onEnded { value in
                guard onAsk != nil else {
                    offset = 0
                    return
                }
                let shouldAsk = value.translation.width < -56
                let reset = { offset = 0 }
                if reduceMotion {
                    reset()
                } else {
                    withAnimation(.easeOut(duration: 0.18), reset)
                }
                guard shouldAsk else { return }
                suppressTap = true
                onAsk?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    suppressTap = false
                }
            }
    }
}
