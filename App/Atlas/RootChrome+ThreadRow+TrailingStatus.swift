import SwiftUI
import AtlasCore

// Thread trailing status — peel de RootChrome+ThreadRow+Trailing.
// New → RootChrome+ThreadRow+NewBadge.swift
// Running → RootChrome+ThreadRow+TrailingStatus+Running.swift
// Count → RootChrome+ThreadRow+TrailingStatus+Count.swift

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        newThreadBadge
        if isRunning {
            rowTrailingRunning
        } else {
            rowTrailingCount
        }
    }
}
