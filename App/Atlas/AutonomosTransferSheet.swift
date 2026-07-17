import SwiftUI
import AtlasCore

/// Folha de transferência — só placement verificado do lock; alvo nunca inventado.
struct AutonomosTransferSheet: View {
    let areaName: String
    let focus: String
    let placement: AtlasAutonomosRuntimePlacement?
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Missão (preservada)") {
                    Text(areaName)
                    Text(focus).font(AtlasFont.mono(11)).foregroundStyle(.secondary)
                }
                Section("Lock atual (verificado)") {
                    if hasPlacement {
                        placementFields
                    } else {
                        Text("Nenhum lock publicado neste recorte — a transferência exige lease vivo.")
                            .font(.footnote).foregroundStyle(.secondary)
                            .accessibilityLabel("Nenhum lock publicado neste recorte. A transferência exige lease vivo.")
                    }
                }
                if hasPlacement {
                    Section("Alvo") {
                        Text("Desconhecido até target_claimed. A fila escolhe o worker; este app não promete host futuro.")
                            .font(.footnote).foregroundStyle(.secondary)
                            .accessibilityLabel(AutonomosTransferSheetA11y.spokenTargetUnknown)
                    }
                    Section("Operador") {
                        TextField("Quem autoriza", text: $actor)
                            .accessibilityIdentifier(A11yID.autonomosTransferActor)
                            .accessibilityHint("nome de quem autoriza a transferência")
                    }
                    Section("Motivo") {
                        TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                            .accessibilityIdentifier(A11yID.autonomosTransferReason)
                            .accessibilityHint("motivo público registrado no ledger")
                    }
                }
            }
            .navigationTitle("Transferir missão")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .accessibilityLabel(AutonomosTransferSheetA11y.spokenCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canConfirm)
                    .accessibilityIdentifier(A11yID.autonomosTransferSubmit)
                    .accessibilityLabel(AutonomosTransferSheetA11y.spokenConfirm(canConfirm: canConfirm))
                    .accessibilityHint(
                        AutonomosTransferSheetA11y.spokenConfirmHint(
                            canConfirm: canConfirm,
                            hasPlacement: hasPlacement
                        )
                    )
                }
            }
            .accessibilityIdentifier(A11yID.autonomosTransferSheet)
        }
        .accessibilityLabel(
            AutonomosTransferSheetA11y.spokenSheet(areaName: areaName, hasPlacement: hasPlacement)
        )
        .accessibilityHint(AutonomosTransferSheetA11y.sheetHint)
    }

    var hasPlacement: Bool { placement?.hasVerifiedPlacement == true }

    var canConfirm: Bool {
        hasPlacement
            && !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
