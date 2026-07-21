import SwiftUI
import UIKit
import AtlasCore

// A11y bind — peel de ConversationChrome EffortSheet.

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel("esforço computacional")
            .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }
}
