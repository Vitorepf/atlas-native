import SwiftUI
import AtlasCore

extension AtlasAutonomosStartRunMode {
    var actionLabel: String { self == .execute ? "Executar de verdade" : "Novo ciclo · ensaio" }
}

struct AutonomosControlSheet: View {
    let action: AtlasAutonomosRunAction
    let onConfirm: (String, String) -> Void

    var body: some View {
        AutonomosReasonSheet(title: label, explainer: "Ação governada — operador e motivo ficam no recibo auditável.", onConfirm: onConfirm)
    }

    private var label: String {
        switch action { case .pause: return "Pausar"; case .resume: return "Retomar"; case .kill: return "Encerrar"; case .clearKill: return "Liberar encerramento" }
    }
}

/// C13: novo ciclo é governado — ensaio é o default; executar exige motivo.
struct AutonomosStartRunSheet: View {
    let mode: AtlasAutonomosStartRunMode
    let onConfirm: (String, String) -> Void

    var body: some View {
        AutonomosReasonSheet(
            title: mode.actionLabel,
            explainer: mode == .execute
                ? "Execução real: motivo auditável obrigatório. O recibo entra NA FILA; só o lease confirma execução."
                : "Ensaio (dry-run): percorre o ciclo sem mutação. O recibo entra na fila.",
            reasonOptional: mode == .dryRun,
            onConfirm: onConfirm
        )
    }
}

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
