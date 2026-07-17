import SwiftUI

// Chip numérico do digest — metadado visual; spoken composto vive no container pai.
// Body → AutonomosChrome+DigestChipBody.swift
extension AutonomosChrome {
    @ViewBuilder
    static func digestChip(_ value: String, _ label: String) -> some View {
        DigestChipBody(value: value, label: label)
    }
}
