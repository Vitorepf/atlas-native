import SwiftUI
import AtlasCore

// Selo e resumo falado — peel de ExecutionStateCard (régua ~160).
// Timers → ExecutionStateCard+Timers.swift
// Chrome → ExecutionStateCard+PresentationChrome.swift
// Badge → ExecutionStateCard+KindBadge.swift
// Attention → ExecutionStateCard+Presentation+Attention.swift
// Terminal → ExecutionStateCard+Presentation+Terminal.swift

extension ExecutionStateCard {
    var spokenKind: String? {
        spokenKindAttention ?? spokenKindTerminal
    }
}
