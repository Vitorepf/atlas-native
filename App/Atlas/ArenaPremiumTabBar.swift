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
                    // Controle fala sans (canon §C); seleção é pílula CONTIDA
                    // (o sublinhado vazava para fora da cápsula).
                    Text(tab.rawValue)
                        .atlasSans(15, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.accent : AtlasTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.goldVeil)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.rawValue.lowercased()))
            }
        }
        .padding(4)
        .background(Capsule().fill(AtlasTheme.surface.opacity(0.18)))
        .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
