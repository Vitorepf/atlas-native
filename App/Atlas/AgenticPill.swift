import SwiftUI

/// Face canônica da pílula (star + invite + optional trailing) — WAVE-016.
/// Usada por botão, NavigationLink e Code slots sem re-roll chrome.
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
