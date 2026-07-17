import SwiftUI
import AtlasCore

// Signal stack — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            digestSignalCaptionRow
            digestSignalHeadlineText
            digestSignalMeta
        }
    }
}
