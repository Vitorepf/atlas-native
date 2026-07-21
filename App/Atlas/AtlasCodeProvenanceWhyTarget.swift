import SwiftUI
import AtlasCore

// Why target DTO — peel de AtlasCodeProvenanceSections.

struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}
