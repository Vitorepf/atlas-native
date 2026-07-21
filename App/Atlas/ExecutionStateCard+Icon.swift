import SwiftUI
import AtlasCore

// Execution icon — peel de ExecutionStateCard+PresentationChrome.
// Attention → ExecutionStateCard+Icon+Attention.swift
// Terminal → ExecutionStateCard+Icon+Terminal.swift

extension ExecutionStateCard {
    var icon: String {
        iconAttention ?? iconTerminal
    }

    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}
