import WidgetKit
import SwiftUI
import AtlasCore

// Ênfase do lock accessory — peel de LockRect.

extension LockAccessorySnapshotView {
    func emphasisColor(_ snapshot: AtlasNativeSnapshot) -> Color {
        if LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
            || LockAccessoryA11y.hasAttention(snapshot) {
            return Ink.alert
        }
        return Ink.ink
    }
}
