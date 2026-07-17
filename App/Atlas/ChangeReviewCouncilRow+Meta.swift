import SwiftUI
import AtlasCore

/// Meta secundária do membro do conselho — peel de ChangeReviewCouncilRow.
/// Latency → ChangeReviewCouncilRow+MetaLatency.swift
/// Hash → ChangeReviewCouncilRow+MetaHash.swift

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaRow: some View {
        HStack(spacing: 8) {
            metaHashCode
            metaLatency
        }
    }
}
