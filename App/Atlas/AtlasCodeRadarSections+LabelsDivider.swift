import AtlasCore
import SwiftUI

// Row divider — peel de AtlasCodeRadarSections+Labels.

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}
