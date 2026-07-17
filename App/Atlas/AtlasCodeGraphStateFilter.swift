import SwiftUI
import AtlasCore

// Graph state filter — Label → AtlasCodeGraphStateFilter+Label.swift

enum AtlasCodeGraphStateFilter: String, CaseIterable, Identifiable {
    case all
    case onMain
    case violating
    case healed
    case history

    var id: String { rawValue }
}
