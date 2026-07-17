import SwiftUI
import AtlasCore

// Filtro de área + pílula nova — peel de WorkspaceView+Chrome (régua ≤100).

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

    var newPill: some View {
        NavigationLink(value: Route.new) {
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                    .accessibilityHidden(true)
                Text("Escreva ao Atlas").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Spacer()
                Image(systemName: "mic.fill").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("nova conversa")
        .accessibilityHint("abre o compositor para escrever ao Atlas")
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
