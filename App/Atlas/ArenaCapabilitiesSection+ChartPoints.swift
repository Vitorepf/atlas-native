import SwiftUI
import Charts
import AtlasCore

// Chart points — peel de ArenaCapabilitiesSection+Chart.

extension ArenaCapabilitiesChart {
    struct Point: Identifiable {
        let id = UUID()
        let label: String
        let series: String
        let value: Double
    }

    var points: [Point] {
        capabilities.flatMap { capability in
            [
                capability.score.map { Point(label: capability.labelPt, series: "sem Atlas", value: $0) },
                capability.withAtlas.map { Point(label: capability.labelPt, series: "com Atlas", value: $0) },
            ].compactMap { $0 }
        }
    }
}
