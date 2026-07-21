import SwiftUI

/// Dock único da pílula em superfícies ops (WAVE-005).
/// Fade + pad + pill — Arena shell/dest, Autônomos, Radar.
struct AgenticAskDock<Pill: View>: View {
    @ViewBuilder var pill: () -> Pill

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            pill()
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }
}

extension View {
    /// Sheet presentation canônica do ask agêntico (WAVE-005).
    func agenticAskSheetPresentation() -> some View {
        self
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AtlasTheme.bg)
            .presentationCornerRadius(28)
    }
}
