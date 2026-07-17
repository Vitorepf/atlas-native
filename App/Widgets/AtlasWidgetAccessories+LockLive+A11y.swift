import AtlasCore
import Foundation

/// Spoken labels do lock accessory — peel de LockAccessorySnapshotView (CICLO C residual).
/// Spoken label → +Spoken.swift · Inline → +A11yInline.swift
/// Clock → +A11yClock.swift

enum LockAccessoryA11y {
    static func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        LockAccessoryA11yAttention.hasAttention(snapshot)
    }

    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        LockAccessoryA11yIncident.incidentLine(incident)
    }
}
