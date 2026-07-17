import SwiftUI
import AtlasCore

// Presentation-only chrome shared by RootView / WorkspaceView / SearchView.
// Route + navigation stay in RootView.

/// Label de seção da home (CONVERSAS / OPERAÇÃO / WORKSPACES).
@ViewBuilder
func sectionLabel(_ t: String) -> some View {
    Text(t)
        .font(.system(.caption, weight: .semibold))
        .tracking(1.4)
        .foregroundStyle(AtlasTheme.textTertiary)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 6)
        .padding(.bottom, 12)
}

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State private var on = false
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
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
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

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(.system(.caption))
                            .foregroundStyle(AtlasTheme.alert)
                            .lineLimit(1)
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
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Linha de conversa — compartilhada com a WorkspaceView. O hub é VIVO: a
// conversa com turno executando troca o ícone pelo losango respirando e o
// contador por "executando" — você sabe onde o Atlas trabalha sem entrar.
struct ThreadRow: View {
    let thread: AtlasAiThread
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    private var isNew: Bool { ConversationModel.hasNewerContent(thread) }
    private var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        HStack(spacing: 14) {
            if isRunning {
                BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
            } else {
                Image(systemName: "bubble.left").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            }
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1).truncationMode(.tail)
            Spacer(minLength: 8)
            if isNew && !isRunning {
                Text("novo")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AtlasTheme.goldVeil))
                    .accessibilityLabel("novo desde a última visita")
            }
            if isRunning {
                Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            } else {
                Text("\(thread.messageCount)")
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) {
            if let workspaceTint {
                Rectangle()
                    .fill(workspaceTint.opacity(0.85))
                    .frame(width: 2)
                    .padding(.vertical, 10)
            }
        }
        .contentShape(Rectangle())
        .accessibilityHint(isRunning ? "Atlas executando nesta conversa" : "")
    }
}

private func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}
