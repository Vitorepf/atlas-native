import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Compacta (era floresta de peels) — um arquivo, contrato de a11y estável.
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason: String

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
                    Text(title).accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") {
                    TextField("Quem autoriza", text: $actor)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint("nome de quem autoriza a ação governada")
                }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical)
                        .lineLimit(3...6)
                        .frame(minHeight: 88, alignment: .topLeading)
                        .accessibilityIdentifier(A11yID.autonomosReasonField)
                        .accessibilityHint(
                            reasonOptional
                                ? "motivo auditável opcional no ensaio"
                                : "motivo auditável registrado no ledger"
                        )
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: "Cancelar",
                        spokenLabel: "cancelar ação governada",
                        spokenHint: "fecha sem registrar recibo",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        // Medium: governed pause/end with operator receipt.
                        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                    .accessibilityLabel(
                        canSubmit
                            ? "confirmar \(title.lowercased())"
                            : "confirmar indisponível, preencha operador e motivo"
                    )
                    .accessibilityHint(
                        canSubmit
                            ? "registra operador e motivo no recibo governado"
                            : "preencha quem autoriza e o motivo"
                    )
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(canSubmit ? 9 : 0)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            // Contain without fused sheet label so fields/confirm stay focusable.
            .accessibilityElement(children: .contain)
        }
    }
}
