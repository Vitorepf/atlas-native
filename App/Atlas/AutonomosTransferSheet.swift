import SwiftUI
import AtlasCore

/// Folha de transferência — só placement verificado do lock; alvo nunca inventado.
struct AutonomosTransferSheet: View {
    let areaName: String
    let focus: String
    let placement: AtlasAutonomosRuntimePlacement?
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
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
                    }
                }
                Section("Alvo") {
                    Text("Desconhecido até target_claimed. A fila escolhe o worker; este app não promete host futuro.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") { TextField("Quem autoriza", text: $actor) }
                Section("Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("Transferir missão")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") { onConfirm(actor, reason); dismiss() }
                        .disabled(actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  || reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosTransferSheet)
        }
    }

    private var hasPlacement: Bool {
        guard let p = placement else { return false }
        return p.host != nil || p.environment != nil || p.workspace != nil
            || p.repository != nil || p.branch != nil || p.leaseTTLSeconds != nil
    }

    @ViewBuilder
    private var placementFields: some View {
        if let host = placement?.host?.nonEmpty {
            LabeledContent("host", value: host)
        }
        if let env = placement?.environment?.nonEmpty {
            LabeledContent("ambiente", value: env)
        }
        if let ws = placement?.workspace?.nonEmpty {
            LabeledContent("workspace", value: ws)
        }
        if let repo = placement?.repository?.nonEmpty {
            LabeledContent("repositório", value: repo)
        }
        if let branch = placement?.branch?.nonEmpty {
            LabeledContent("branch", value: branch)
        }
        if let ttl = placement?.leaseTTLSeconds {
            LabeledContent("lease", value: "\(ttl)s")
        }
    }
}
