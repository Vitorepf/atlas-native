import WidgetKit
import SwiftUI
import AtlasCore

// Install prompt — peel de AtlasWidgetViews.

struct InstallPromptView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("✦ Atlas")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.gold)
            Text("abra o Atlas")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink)
        }
    }
}
