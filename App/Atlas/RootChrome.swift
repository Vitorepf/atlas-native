import AtlasCore
import SwiftUI

// Cycle 034 fuse → RootChrome.swift

// Presentation-only chrome shared by RootView / WorkspaceView / SearchView.
// Route + navigation stay in RootView.
// Rows: RootChrome+Rows.swift · Controls: RootChrome+Controls.swift
// A11y: RootChrome+SectionA11y.swift

/// Label de seção da home (CONVERSAS / OPERAÇÃO / WORKSPACES).
@MainActor
@ViewBuilder
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    // A linha premium do site: hairlines em fade ladeando o rótulo.
    HStack(spacing: 12) {
        LinearGradient(colors: [AtlasTheme.separator.opacity(0), AtlasTheme.separator],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        Text(t)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.55)
            .foregroundStyle(AtlasTheme.textTertiary)
            .fixedSize()
        LinearGradient(colors: [AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
    }
    .padding(.horizontal, AtlasTheme.Space.screen)
    .padding(.top, 18)
    .padding(.bottom, 11)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isHeader)
    .homeSectionA11yID(accessibilityID)
}

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State var on = false
    var body: some View {
        Text("✦")
            .font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(on ? 1.08 : 1).opacity(on ? 0.8 : 1)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { on = true }
                }
            }
            .accessibilityHidden(true)
    }
}

private struct HomeSectionA11yID: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id {
            content.accessibilityIdentifier(id)
        } else {
            content
        }
    }
}

extension View {
    func homeSectionA11yID(_ id: String?) -> some View {
        modifier(HomeSectionA11yID(id: id))
    }
}

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .atlasSans(15, .medium).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 44, height: 44).atlasGlassCircle()
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}

struct CircleButton: View {
    let icon: String
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            circleButtonLabel
        }
        .accessibilityAddTraits(.isButton)
    }
}

extension CircleButton {
    @ViewBuilder
    var badgeOverlay: some View {
        if badge {
            Circle()
                .fill(AtlasCodePalette.alert)
                .frame(width: 9, height: 9)
                .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 1.5))
                .offset(x: 1, y: -1)
                .accessibilityHidden(true)
        }
    }
}
