import SwiftUI
import AtlasCore

// Stack AGORA — peel de ArenaNowSection+Body.
// Header → ArenaNowSection+StackHeader.swift

extension ArenaNowSection {
    var nowSectionStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            nowSectionHeader
            nowRunRows
            nowLiveActivityNote
        }
        .padding(16)
        .atlasCard()
    }
}
