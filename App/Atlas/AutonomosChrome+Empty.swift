import SwiftUI
import AtlasCore

/// Card vazio Autônomos — caption + copy editorial (frota, histórico, digest).
/// Fleet → AutonomosChrome+FleetEmpty.swift
/// Fleet copy → AutonomosChrome+FleetEmptyCopy.swift
/// Chrome → AutonomosChrome+EmptyChrome.swift
/// CopyStack → AutonomosChrome+Empty+CopyStack.swift

struct AutonomosCardEmptyState: View {
    let caption: String
    let copy: String
    let accessibilityIdentifier: String

    var body: some View {
        emptyCardChrome(emptyCopyStack)
    }
}
