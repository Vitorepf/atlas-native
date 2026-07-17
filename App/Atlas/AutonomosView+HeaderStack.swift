import SwiftUI
import AtlasCore

// Autônomos header stack — peel de AutonomosView.

extension AutonomosView {
    var autonomosHeaderStack: some View {
        VStack(spacing: 0) {
            AutonomosViewHeader(
                auditModeEnabled: session.auditModeEnabled,
                canRefresh: model.selectedArea != nil,
                isHealthy: isHeaderHealthy,
                reduceMotion: reduceMotion,
                onBack: { dismiss() },
                onRefresh: { Task { await model.refreshSelected() } }
            )
            autonomosContentAnimated
        }
    }
}
