import SwiftUI
import AtlasCore

// Card chrome — peel de AutonomosInfoLine.

extension AutonomosInfoLine {
    func infoLineCard(_ text: String) -> some View {
        Text(text)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control)
    }
}
