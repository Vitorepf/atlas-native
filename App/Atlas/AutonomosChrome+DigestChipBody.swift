import SwiftUI

// Corpo visual do chip — peel de AutonomosChrome+DigestChip.
// ValueStack → AutonomosChrome+DigestChipBody+ValueStack.swift

struct DigestChipBody: View {
    let value: String
    let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        digestChipValueStack
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Capsule().fill(AtlasTheme.bgRecessed))
            .accessibilityHidden(true)
    }
}
