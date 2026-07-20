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

    /// Tabs do grafo AX — sem “história” (ruído; o scroll já é história).
    static let grafoTabs: [AtlasCodeGraphStateFilter] = [.all, .onMain, .violating, .healed]
}
