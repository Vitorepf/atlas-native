import SwiftUI
import AtlasCore

// Status capsule chrome — peel de AtlasCodeGraphChrome+Status.

extension AtlasCodeView {
    func statusCapsuleChrome<Content: View>(_ content: Content) -> some View {
        content
            .foregroundStyle(statusCapsuleColor)
            .padding(.horizontal, 15)
            .padding(.vertical, 7)
            .background(Capsule().fill(statusCapsuleColor.opacity(0.09)))
            .overlay(Capsule().strokeBorder(statusCapsuleColor.opacity(0.35), lineWidth: 1))
            .frame(maxWidth: .infinity, alignment: .center)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
            .accessibilityLabel(AtlasCodeGraphA11y.spokenStatus(
                scanState: model.scanState, headline: model.statusHeadline
            ))
            .accessibilityIdentifier(A11yID.codeStatus)
    }
}
