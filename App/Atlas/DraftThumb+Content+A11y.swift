import SwiftUI
import UIKit
import AtlasCore

// A11y + interaction — peel de DraftThumb+Content.

extension DraftThumb {
    func thumbContentA11y<V: View>(_ framed: V) -> some View {
        framed
            .overlay { stateVeil }
            .onTapGesture {
                if let m = failedMessage { onFailedTap("falhou: \(m)") }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DraftThumbA11y.spokenThumb(draft))
            .accessibilityValue(failedMessage.map { DraftThumbA11y.spokenFailedValue($0) } ?? "")
            .accessibilityHint(failedMessage != nil ? DraftThumbA11y.failedHint : "")
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: draft.state)
    }
}
