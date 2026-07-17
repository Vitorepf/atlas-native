import SwiftUI
import AtlasCore

// Identifier bind — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    func digestSignalIdentifier(_ view: some View) -> some View {
        view.accessibilityIdentifier(A11yID.autonomosOperationDigest)
    }
}
