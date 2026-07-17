import SwiftUI
import AtlasCore

// Rotor entry — peel de AtlasCodeView+GraphListRows+CommitRow.

extension AtlasCodeView {
    func graphCommitRowRotor<Row: View>(_ row: Row, node: AtlasCodeGraphNode) -> some View {
        row.accessibilityRotorEntry(id: node.id, in: graphRotor)
    }
}
