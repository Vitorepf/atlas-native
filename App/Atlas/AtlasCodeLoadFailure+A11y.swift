import SwiftUI

// A11y shell — peel de AtlasCodeLoadFailure.

extension AtlasCodeLoadFailureEmpty {
    var failureA11y: some View {
        failureStack
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(headline). \(message)")
            .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}
