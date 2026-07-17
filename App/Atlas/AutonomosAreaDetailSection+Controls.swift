import SwiftUI
import AtlasCore

// Controles da área — peel de AutonomosAreaDetailSection.

extension AutonomosAreaDetailSection {
    var areaControls: some View {
        AutonomosAreaControls(
            areaName: area.areaName,
            isPaused: model.live?.isPaused == true,
            canControl: model.canControlSelectedArea,
            onResume: { control = .resume },
            onPause: { control = .pause },
            onTransfer: { showTransferSheet = true },
            onKill: { control = .kill },
            onDryRun: { startRunMode = .dryRun },
            onExecute: { startRunMode = .execute }
        )
    }
}
