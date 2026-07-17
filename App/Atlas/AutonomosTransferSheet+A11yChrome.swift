import SwiftUI
import AtlasCore

// Transfer a11y chrome — peel de AutonomosTransferSheet.

extension AutonomosTransferSheet {
    func transferA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(
                AutonomosTransferSheetA11y.spokenSheet(areaName: areaName, hasPlacement: hasPlacement)
            )
            .accessibilityHint(AutonomosTransferSheetA11y.sheetHint)
    }
}
