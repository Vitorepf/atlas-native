import SwiftUI
import AtlasCore

// Execution state card stack — peel de ExecutionStateCard.

extension ExecutionStateCard {
    var stateCardStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            stateHeader
            detailLine
            metaLines
            actionButtons
        }
    }
}
