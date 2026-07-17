import SwiftUI
import AtlasCore

// Repo/branch placement — peel de AutonomosTransferSheet+Placement.

extension AutonomosTransferSheet {
    @ViewBuilder
    var placementRepoFields: some View {
        if let repo = placement?.repository?.nonEmpty {
            LabeledContent("repositório", value: repo)
        }
        if let branch = placement?.branch?.nonEmpty {
            LabeledContent("branch", value: branch)
        }
    }
}
