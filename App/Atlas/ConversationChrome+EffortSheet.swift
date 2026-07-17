import SwiftUI
import UIKit
import AtlasCore

// Pick → ConversationChrome+EffortSheet+Pick.swift
// Rows → ConversationChrome+EffortSheet+Rows.swift
struct EffortSheet: View {
    var model: ConversationModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Esforço") {
            Text("vale para o próximo envio; automático deixa o Atlas Decide escolher")
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityHidden(true)
            effortRows
        }
        .accessibilityIdentifier(A11yID.effortSheet)
        .accessibilityLabel("esforço computacional")
        .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }
}
