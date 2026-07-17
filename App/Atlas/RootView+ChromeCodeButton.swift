import SwiftUI
import AtlasCore

// Code hub top bar button — peel de RootView+Chrome.

extension RootView {
    var topBarCodeButton: some View {
        CircleButton(icon: "point.3.connected.trianglepath.dotted",
                       badge: codeHub?.exception != nil) { path.append(Route.code) }
            .accessibilityLabel(RootHomeSections.codeTopBarLabel(hub: codeHub))
            .accessibilityHint("abre radar de repositórios")
            .accessibilityIdentifier(A11yID.topbarCode)
    }
}
