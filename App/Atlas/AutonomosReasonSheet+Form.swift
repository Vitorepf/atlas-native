import SwiftUI

// Form + toolbar — peel de AutonomosReasonSheet.

extension AutonomosReasonSheet {
    var reasonForm: some View {
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
    }

    @ToolbarContentBuilder
    var reasonToolbar: some ToolbarContent {
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
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onConfirm(actor, reason)
                dismiss()
            }
            .disabled(!canSubmit)
            .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
            .accessibilityLabel(spokenConfirmLabel(canSubmit: canSubmit))
            .accessibilityHint(spokenConfirmHint(canSubmit: canSubmit))
        }
    }
}
