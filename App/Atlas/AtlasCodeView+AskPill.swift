import SwiftUI
import AtlasCore

// Pílula de pergunta — peel de AtlasCodeView+Graph (régua ~160).

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        HStack(spacing: 9) {
            Text("✦")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Text(anchorLegend ?? "pergunte sobre este repositório")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
                .accessibilityIdentifier(A11yID.codeAskAnchorNote)
            Spacer(minLength: 0)
            if askModel.isAnchoring {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    askModel.clear()
                } label: {
                    Text("mostrar tudo")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AtlasCodeAskPillA11y.clearLabel)
                .accessibilityHint(AtlasCodeAskPillA11y.clearHint)
                .accessibilityIdentifier(A11yID.codeAskClear)
            }
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
        .contentShape(Capsule())
        .onTapGesture {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            askDraft = ""
            showsAskCard = true
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.22),
            value: AtlasCodeAskPillA11y.pillPhaseID(
                isAnchoring: askModel.isAnchoring,
                anchorLegend: anchorLegend
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            AtlasCodeAskPillA11y.spokenPill(
                isAnchoring: askModel.isAnchoring,
                anchorLegend: anchorLegend
            )
        )
        .accessibilityHint(AtlasCodeAskPillA11y.pillHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.codeAskPill)
    }
}
