import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

@MainActor
@ViewBuilder
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    HStack(spacing: 12) {
        LinearGradient(colors: [AtlasTheme.separator.opacity(0), AtlasTheme.separator],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        Text(t)
            .font(AtlasFont.mono(10, .semibold))
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

struct CircleButton: View {
    let icon: String
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .atlasSans(15, .medium).foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44).atlasGlassCircle()
                .overlay(alignment: .topTrailing) {
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
        .accessibilityAddTraits(.isButton)
    }
}

func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    var a11yID: String?
    var spokenOverride: String?
    var spokenHint: String?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenOverride ?? WorkspaceThreadJudgment.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint(spokenHint ?? "abre \(name)")
        .accessibilityIdentifier(a11yID ?? "")
    }

    var rowContent: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    .accessibilityHidden(true)
                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(.caption))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 8)
            if badge {
                Circle()
                    .fill(AtlasTheme.alert)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
            if let count {
                Text("\(count)")
                    .font(AtlasFont.mono(12, .medium))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.55))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}

