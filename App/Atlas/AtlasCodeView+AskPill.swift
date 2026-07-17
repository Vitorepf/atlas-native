import SwiftUI
import AtlasCore

// Pílula de pergunta — peel de AtlasCodeView+Graph (régua ~160).
// Clear → AtlasCodeView+AskPillClear.swift · Content → +AskPillContent.swift

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        askPillContent
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
