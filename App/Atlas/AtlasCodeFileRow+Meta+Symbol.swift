import SwiftUI
import AtlasCore

// File status symbol — peel de AtlasCodeFileRow+Meta.
// Mutate → AtlasCodeFileRow+Meta+Symbol+Mutate.swift
// Transform → AtlasCodeFileRow+Meta+Symbol+Transform.swift

extension AtlasCodeFileRow {
    var symbol: String {
        symbolMutate ?? symbolTransform ?? "questionmark"
    }
}
