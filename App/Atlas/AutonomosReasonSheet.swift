import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason = ""

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

    private var canSubmit: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (reasonOptional || !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação governada") {
                    Text(title)
                        .accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") {
                    TextField("Quem autoriza", text: $actor)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint(spokenActorHint())
                }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                        .accessibilityIdentifier(A11yID.autonomosReasonField)
                        .accessibilityHint(spokenReasonHint())
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        dismiss()
                    }
                    .accessibilityLabel("cancelar ação governada")
                    .accessibilityHint("fecha sem registrar recibo")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        onConfirm(actor, reason)
                        dismiss()
                    }
                        .disabled(!canSubmit)
                        .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                        .accessibilityLabel(spokenConfirmLabel(canSubmit: canSubmit))
                        .accessibilityHint(spokenConfirmHint(canSubmit: canSubmit))
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
        }
    }
}
