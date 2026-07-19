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
                        .atlasSans(15, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .shadow(color: .black.opacity(0.28), radius: 4, y: 1)
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
