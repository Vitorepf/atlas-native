import SwiftUI
import AtlasCore

// Métricas — peel de AutonomosChrome.
// ValueStack → AutonomosChrome+Metrics+ValueStack.swift
// CardChrome → AutonomosChrome+Metrics+CardChrome.swift

struct FleetMetric: View {
    let value: String; let label: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        metricCardChrome
    }
}
