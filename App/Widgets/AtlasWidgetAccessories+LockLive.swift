import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot widget surfaces (lock accessory / live session)
// Circular → AtlasWidgetAccessories+LockCircular.swift
// Spoken → AtlasWidgetAccessories+LockLive+SpokenLabel.swift
// Content → AtlasWidgetAccessories+LockLive+Content.swift
// Empty → AtlasWidgetAccessories+LockLive+Empty.swift

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                lockAccessoryContent(snapshot)
            } else {
                lockAccessoryEmpty
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
    }
}
