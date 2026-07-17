import SwiftUI
import AtlasCore

// Activity rows — peel de ExecutionProof+Expanded.
// Copy → ExecutionProof+ActivityRowCopy.swift
// Row cell → ExecutionProof+ActivityRows+RowCell.swift

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}
