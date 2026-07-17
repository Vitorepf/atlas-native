import SwiftUI
import AtlasCore

// Identity fields — peel de AutonomosDetailLedgerRows+FindingFields.

extension AutonomosDetailLedgerFindings {
    @ViewBuilder
    static func findingIdentityFields(_ item: AtlasAutonomosFinding) -> some View {
        AutonomosDetailChrome.field("hash", item.findingHash)
        AutonomosDetailChrome.field("source", item.source)
        AutonomosDetailChrome.field("owner", item.sourceOwner)
        AutonomosDetailChrome.field("gap", item.gapKind)
    }
}
