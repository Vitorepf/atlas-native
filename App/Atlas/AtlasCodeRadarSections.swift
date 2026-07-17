import AtlasCore
import SwiftUI

// MARK: - Chrome do AtlasCodeRadarView (peel de AtlasCodeRadarSections)
// Capsules → +Capsules · Labels → +Labels

struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        // Silêncio = produto: saudável (sem violações) → caption quieta, sem
        // chrome de alarme/afirmação verde. Barulho só com exceção real.
        Group {
            switch model.scanState {
            case .clean, .unknown:
                silentCaption
            case .violating:
                alarmCapsule
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.scanState)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(spokenStatus(model: model))
        .accessibilityIdentifier(A11yID.radarStatus)
    }
}
