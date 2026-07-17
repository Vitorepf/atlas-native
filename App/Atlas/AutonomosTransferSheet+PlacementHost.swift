import SwiftUI
import AtlasCore

// Host/env/workspace placement — peel de AutonomosTransferSheet+Placement.

extension AutonomosTransferSheet {
    @ViewBuilder
    var placementHostFields: some View {
        if let host = placement?.host?.nonEmpty {
            LabeledContent("host", value: host)
        }
        if let env = placement?.environment?.nonEmpty {
            LabeledContent("ambiente", value: env)
        }
        if let ws = placement?.workspace?.nonEmpty {
            LabeledContent("workspace", value: ws)
        }
    }
}
