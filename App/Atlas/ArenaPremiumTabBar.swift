import SwiftUI

struct ArenaPremiumTabBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selection: ArenaPremiumTab
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArenaPremiumTab.allCases) { tab in
                Button {
                    withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { selection = tab }
                } label: {
                    // Controle fala sans (canon §C); seleção = pílula neutra
                    // ELEVADA (padrão do segmented nativo), não véu de ouro —
                    // ouro é ESTADO, não seleção de controle.
                    Text(tab.rawValue)
                        .atlasSans(13, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .shadow(color: .black.opacity(0.22), radius: 5, y: 1)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabAccessibilityLabel(tab))
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.a11yKey))
            }
        }
        .padding(3)
        .background(Capsule().fill(AtlasTheme.bgRecessed.opacity(0.92)))
        .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.7), lineWidth: 1))
    }

    private func tabAccessibilityLabel(_ tab: ArenaPremiumTab) -> String {
        switch tab {
        case .now: "Agora"
        case .fleet: "Frota"
        case .capabilities: "Capacidades"
        case .results: "Motor"
        }
    }
}
