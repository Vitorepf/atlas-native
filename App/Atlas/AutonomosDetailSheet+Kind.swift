import SwiftUI
import AtlasCore

/// Kind enum da folha pública Autônomos — peel de AutonomosDetailSheet.
/// Title → AutonomosDetailSheet+Kind+Title.swift

enum AutonomosDetailSheet: String, Identifiable {
    case workOrders
    case inbox
    case budgets
    case findings

    var id: String { rawValue }
}
