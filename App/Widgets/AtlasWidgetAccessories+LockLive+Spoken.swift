import AtlasCore
import Foundation

/// Spoken label do lock — peel de LockAccessoryA11y.
// Branch → AtlasWidgetAccessories+LockLive+Spoken+Branch.swift
// Stale → AtlasWidgetAccessories+LockLive+Spoken+Stale.swift

extension LockAccessoryA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, age: String) -> String {
        var parts: [String] = ["Atlas lock"]
        parts.append(contentsOf: spokenLabelBranchLines(snapshot: snapshot))
        if let suffix = spokenLabelStaleSuffix(stale: stale, age: age) {
            parts.append(suffix)
        }
        return parts.joined(separator: ", ")
    }
}
