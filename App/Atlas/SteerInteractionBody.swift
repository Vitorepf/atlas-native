import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

extension SteerInteractionSheet {
    /// WAVE-053: face + submit from Judgment.
    var steerFace: ConversationSteerFace {
        ConversationSteerJudgment.face(
            instruction: instruction,
            last: model.lastSteerReceipt,
            traceId: traceId
        )
    }

    var canSubmit: Bool {
        ConversationSteerJudgment.allowsSubmit(instruction: instruction)
    }

    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        ConversationSteerJudgment.spokenReceipt(receipt)
    }

    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        ConversationSteerJudgment.spokenScope(scope)
    }

    func spokenSheetHint() -> String {
        "instrução entra no próximo checkpoint seguro; o Atlas pode recusar"
    }

    func spokenSubmitLabel(canSubmit: Bool) -> String {
        ConversationSteerJudgment.spokenSubmitLabel(allowsSubmit: canSubmit)
    }

    func spokenSubmitHint(canSubmit: Bool) -> String {
        ConversationSteerJudgment.spokenSubmitHint(allowsSubmit: canSubmit)
    }
}

extension SteerInteractionSheet {
    func steerA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.steerSheet)
            .accessibilityLabel("redirecionar execução \(traceId.rawValue)")
            .accessibilityHint(spokenSheetHint())
    }
}

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            formHeader
            instructionField
            formReceiptLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}

extension SteerInteractionSheet {
    var formHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Redirecionar")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("A instrução entra no próximo checkpoint seguro desta execução. O Atlas pode recusar e devolver o motivo público.")
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            formScopePicker
        }
    }
}

extension SteerInteractionSheet {
    var formScopePicker: some View {
        // WAVE-053: product PT labels (not wire raw current_step/replan).
        Picker("Escopo", selection: $scope) {
            ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                Text(ConversationSteerJudgment.scopeLabel(scope)).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier(A11yID.steerScope)
        .accessibilityLabel(spokenScopeLabel(scope))
    }
}

extension SteerInteractionSheet {
    @ViewBuilder
    var formReceiptLine: some View {
        if let receipt = matchedReceipt {
            receiptLine(receipt)
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityIdentifier(A11yID.steerReceipt)
                .accessibilityLabel(spokenReceiptLabel(receipt))
        }
    }
}

extension SteerInteractionSheet {
    var instructionField: some View {
        TextField("O que muda a partir daqui?", text: $instruction, axis: .vertical)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent)
            .lineLimit(3...7)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityIdentifier(A11yID.steerInstruction)
            .accessibilityHint("descreve o que deve mudar na execução")
    }
}

extension SteerInteractionSheet {
    var steerNavigationStack: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                formContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { steerToolbar }
        }
    }
}

extension SteerInteractionSheet {
    var matchedReceipt: AtlasInteractionSteerResponse? {
        ConversationSteerJudgment.matchedReceipt(
            last: model.lastSteerReceipt,
            traceId: traceId
        )
    }
}

extension SteerInteractionSheet {
    func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        // WAVE-053: copy + tint from Judgment face.
        Text(ConversationSteerJudgment.receiptLine(receipt))
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .accessibilityValue(receipt.isAccepted ? "accepted" : "rejected")
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        steerCancelItem
        steerSubmitItem
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerCancelItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar redirecionamento",
                spokenHint: "fecha sem enviar instrução",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerSubmitItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            steerSubmitButton
        }
    }
}

extension SteerInteractionSheet {
    var steerSubmitButton: some View {
        Button("Enviar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSubmit(instruction, scope)
        }
        .disabled(!canSubmit)
        .accessibilityIdentifier(A11yID.steerSubmit)
        .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
        .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
        .accessibilityValue(steerFace.productWord)
    }
}

