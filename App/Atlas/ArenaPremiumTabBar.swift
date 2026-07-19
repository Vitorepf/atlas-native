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
                    Text(tab.rawValue)
                        .font(AtlasFont.serif(16))
                        .foregroundStyle(selection == tab ? AtlasTheme.accent : AtlasTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .overlay(alignment: .bottom) {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.accent)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.rawValue.lowercased()))
            }
        }
        .padding(.horizontal, 8)
        .background(Capsule().fill(AtlasTheme.surface.opacity(0.18)))
        .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
