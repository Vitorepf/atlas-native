import SwiftUI
import AtlasCore

// Filtro de área — peel de WorkspaceView+Chrome (régua ≤100).
// New pill → WorkspaceView+ChromeNewPill.swift

extension WorkspaceView {
    var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AtlasArea.allCases) { a in
                    let active = a == area
                    Button {
                        if reduceMotion {
                            area = a
                        } else {
                            withAnimation(AtlasMotion.editorial) { area = a }
                        }
                    } label: {
                        Text(a.label)
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("área \(a.label)")
                    .accessibilityHint("filtra conversas já carregadas")
                    .accessibilityAddTraits(active ? .isSelected : [])
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
    }
}
