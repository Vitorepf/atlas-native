import SwiftUI
import AtlasCore

struct SteerInteractionSheet: View {
    let traceId: TraceID
    var model: ConversationModel
    let onSubmit: (String, AtlasInteractionSteerScope) -> Void

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var instruction = ""
    @State var scope: AtlasInteractionSteerScope = .currentStep

    var canSubmit: Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var matchedReceipt: AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                formContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: "Cancelar",
                        spokenLabel: "cancelar redirecionamento",
                        spokenHint: "fecha sem enviar instrução",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enviar") {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onSubmit(instruction, scope)
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.steerSubmit)
                    .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
                    .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
                }
            }
        }
        .accessibilityIdentifier(A11yID.steerSheet)
        .accessibilityLabel("redirecionar execução \(traceId.rawValue)")
        .accessibilityHint(spokenSheetHint())
    }
}
