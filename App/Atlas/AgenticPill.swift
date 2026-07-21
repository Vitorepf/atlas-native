import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: AgenticPill + AskDock + OccasionPack fused

// MARK: - AgenticPill

struct AgenticPillFace<Trailing: View>: View {
    let invite: String
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            RootView.HomeComposerStar()
            Text(invite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .atlasAgenticPillChrome()
    }
}

extension AgenticPillFace where Trailing == EmptyView {
    init(invite: String) {
        self.invite = invite
        self.trailing = { EmptyView() }
    }
}

/// Chrome único da pílula agêntica (baseline Home craft).
/// Só mudam: `invite`, `action`, a11y, trailing opcional (Code clear).
/// Pack nunca na cara — só viaja em `turnFacts`.
struct AgenticPill<Trailing: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let invite: String
    var accessibilityId: String = A11yID.arenaPremiumAskPill
    var accessibilityHintText: String = "Abre conversa com o contexto desta tela"
    @ViewBuilder var trailing: () -> Trailing
    let action: () -> Void

    var body: some View {
        Button(action: {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            action()
        }) {
            AgenticPillFace(invite: invite, trailing: trailing)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(invite)
        .accessibilityHint(accessibilityHintText)
        .accessibilityIdentifier(accessibilityId)
    }
}

extension AgenticPill where Trailing == EmptyView {
    init(
        invite: String,
        accessibilityId: String = A11yID.arenaPremiumAskPill,
        accessibilityHintText: String = "Abre conversa com o contexto desta tela",
        action: @escaping () -> Void
    ) {
        self.invite = invite
        self.accessibilityId = accessibilityId
        self.accessibilityHintText = accessibilityHintText
        self.trailing = { EmptyView() }
        self.action = action
    }
}

/// Compat: call sites antigos Arena/Autônomos.
typealias ArenaPremiumAskPill = AgenticPill
// MARK: - AgenticAskDock

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
// MARK: - AgenticOccasionPack

struct AgenticOccasionPack: Equatable {
    enum CanDo: String, Equatable {
        /// Chat NL de leitura/julgamento; sem tool write.
        case readChat = "read_chat"
        /// Só status/headline; sem chat útil além de perguntar.
        case statusOnly = "status_only"
        /// Run/stop/pause só via CTA da face — NL não autoriza write.
        case ctaOnlyRunStop = "cta_only_run_stop"
        /// Controles locais da face (pause/retomar) + chat de leitura.
        case faceCTALocal = "face_cta_local_plus_read_chat"
    }

    var surface: String
    var subject: String
    var anchors: [String] = []
    var facts: [String] = []
    var absences: [String] = []
    var canDo: CanDo
    /// Bloco opcional (ex.: server ask facts) anexado após a gramática.
    var appendix: String? = nil

    /// Render key:value estável — mesma forma em todas as faces ops.
    func render() -> String {
        var lines: [String] = [
            "surface: \(surface)",
            "subject: \(subject)",
        ]
        if anchors.isEmpty {
            lines.append("anchors: []")
        } else {
            lines.append("anchors:")
            for a in anchors {
                lines.append("- \(a)")
            }
        }
        if facts.isEmpty {
            lines.append("facts: []")
        } else {
            lines.append("facts:")
            for f in facts {
                lines.append("- \(f)")
            }
        }
        if absences.isEmpty {
            lines.append("absences: []")
        } else {
            lines.append("absences:")
            for a in absences {
                lines.append("- \(a)")
            }
        }
        lines.append("can_do: \(canDo.rawValue)")
        if let appendix = appendix?.trimmingCharacters(in: .whitespacesAndNewlines), !appendix.isEmpty {
            lines.append("---")
            lines.append("appendix:")
            lines.append(appendix)
        }
        return lines.joined(separator: "\n")
    }
}
