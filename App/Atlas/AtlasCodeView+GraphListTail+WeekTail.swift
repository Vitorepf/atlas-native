import SwiftUI
import AtlasCore

// Week/heal tail — peel de AtlasCodeView+GraphListTail.

extension AtlasCodeView {
    @ViewBuilder
    var graphListWeekTail: some View {
        if model.week != nil || model.hasHealReceipt {
            weekSection
                .padding(.top, 22)
        }
    }
}
