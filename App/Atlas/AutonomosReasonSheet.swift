import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
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

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação governada") {
                    Text(title)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") { TextField("Quem autoriza", text: $actor) }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") { onConfirm(actor, reason); dismiss() }
                        .disabled(actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  || (!reasonOptional && reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                }
            }
        }
    }
}
