import SwiftUI

// Controls stack — peel de AutonomosAreaSection.

extension AutonomosAreaControls {
    @ViewBuilder
    var areaControlsStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            primaryButtons
            cycleButtons
        }
    }
}
