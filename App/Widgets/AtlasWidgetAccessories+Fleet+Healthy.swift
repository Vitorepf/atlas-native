import WidgetKit
import SwiftUI
import AtlasCore

// Fleet healthy/unread state — peel de AtlasWidgetAccessories+Fleet+State.
// Scanned → AtlasWidgetAccessories+Fleet+Healthy+Scanned.swift
// Unread → AtlasWidgetAccessories+Fleet+Healthy+Unread.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyOrUnread(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            fleetHealthyScanned(snapshot, scanned: scanned)
        } else {
            fleetHealthyUnread
        }
    }
}
