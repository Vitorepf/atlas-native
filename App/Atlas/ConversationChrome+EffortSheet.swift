import SwiftUI
import UIKit
import AtlasCore

struct EffortSheet: View {
    var model: ConversationModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        SheetShell(title: "Esforço") {
            Text("vale para o próximo envio; automático deixa o Atlas Decide escolher")
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("esforço vale para o próximo envio; automático deixa o Atlas Decide escolher")
            ForEach(AtlasComputeEffort.allCases, id: \.self) { effort in
                let selected = effort == model.effort
                SheetRow(
                    label: effort.shortLabel.capitalized,
                    sub: ComposerSheetA11y.effortSubtitle(effort),
                    selected: selected,
                    accessibilityLabel: ComposerSheetA11y.effortLabel(effort, selected: selected),
                    accessibilityIdentifier: A11yID.effortRow(effort.rawValue)
                ) {
                    pick(effort)
                }
            }
        }
        .accessibilityIdentifier(A11yID.effortSheet)
        .accessibilityLabel("esforço computacional")
        .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }

    private func pick(_ effort: AtlasComputeEffort) {
        model.effort = effort
        UserDefaults.standard.set(effort.rawValue, forKey: ConversationModel.effortPreferenceKey)
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        dismiss()
    }
}
