import WidgetKit
import SwiftUI
import AtlasCore

// Header strip — peel de LiveSessionWidgetView content.

extension LiveSessionWidgetView {
    func liveSessionHeader(stale: Bool, age: String) -> some View {
        HStack {
            Text("✦ Sessão viva")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .accessibilityHidden(true)
            Spacer()
            if stale {
                Text("visto \(age)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Ink.alert)
                    .accessibilityHidden(true)
            }
        }
    }
}
