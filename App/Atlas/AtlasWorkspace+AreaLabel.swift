import SwiftUI
import AtlasCore

// AtlasArea labels — peel de AtlasWorkspace.
// Domain → AtlasWorkspace+AreaLabel+Domain.swift

extension AtlasArea {
    var label: String {
        labelDomain ?? "Tudo"
    }
}
