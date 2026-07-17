import SwiftUI
import AtlasCore

struct AutonomosDetailChipButton: View {
    let label: String
    let kind: AutonomosDetailSheet
    var spokenLabel: String? = nil
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: chipPressAction) {
            chipLabel
        }
        .buttonStyle(PressableScale())
        .autonomosDetailChipA11y(label: label, spokenLabel: spokenLabel, kind: kind)
    }
}
