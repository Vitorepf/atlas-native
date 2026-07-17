import SwiftUI
import AtlasCore

// Signal router — peel de AutonomosOperationDigestSection.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestBody: some View {
        let hasSignal = deliveredTotal > 0 || pendingCount > 0 || inboxCount > 0 || incidentPresent
        if hasSignal {
            digestSignalBody
        } else {
            digestQuietBody
        }
    }
}
