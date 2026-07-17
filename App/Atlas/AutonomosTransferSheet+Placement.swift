import SwiftUI
import AtlasCore

// Campos de placement verificado — peel de AutonomosTransferSheet (régua ≤100).

extension AutonomosTransferSheet {
    @ViewBuilder
    var placementFields: some View {
        if let host = placement?.host?.nonEmpty {
            LabeledContent("host", value: host)
        }
        if let env = placement?.environment?.nonEmpty {
            LabeledContent("ambiente", value: env)
        }
        if let ws = placement?.workspace?.nonEmpty {
            LabeledContent("workspace", value: ws)
        }
        if let repo = placement?.repository?.nonEmpty {
            LabeledContent("repositório", value: repo)
        }
        if let branch = placement?.branch?.nonEmpty {
            LabeledContent("branch", value: branch)
        }
        if let acquired = placement?.acquiredAt?.nonEmpty {
            LabeledContent("adquirido", value: acquired)
        }
        if let ttl = placement?.leaseTTLSeconds {
            LabeledContent("lease", value: "\(ttl)s")
        }
    }
}
