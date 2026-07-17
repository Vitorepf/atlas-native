import SwiftUI
import AtlasCore

// Run rows — peel de ArenaNowSection.
// Content → ArenaNowSection+RowContent.swift

extension ArenaNowSection {
    @ViewBuilder
    var nowRunRows: some View {
        ForEach(runs) { run in
            nowRunRow(run)
        }
    }
}
