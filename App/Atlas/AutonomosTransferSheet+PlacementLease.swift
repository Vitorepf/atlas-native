import SwiftUI
import AtlasCore

// Placement lease/acquired — peel de AutonomosTransferSheet+Placement.

extension AutonomosTransferSheet {
    @ViewBuilder
    var placementLeaseFields: some View {
        if let acquired = placement?.acquiredAt?.nonEmpty {
            LabeledContent("adquirido", value: acquired)
        }
        if let ttl = placement?.leaseTTLSeconds {
            LabeledContent("lease", value: "\(ttl)s")
        }
    }
}
