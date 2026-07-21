import Foundation
import Observation
import AtlasCore

/// Autônomo do operador (escopo fechado). Persistência Server = OBRA §5.
/// Em memória no AutonomosModel até existir create no Core (casca não faz storage).
struct AutonomosUnit: Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var charter: String
    var createdAt: Date
    var paused: Bool

    var ageLabel: String {
        let seconds = max(0, Int(Date().timeIntervalSince(createdAt)))
        if seconds < 60 { return "agora" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86_400 { return "\(seconds / 3600)h" }
        let days = seconds / 86_400
        return days == 1 ? "1 dia" : "\(days) dias"
    }
}

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
/// Load → AutonomosModel+Load.swift · comandos → +Control.swift.
/// Face v9: catálogo local + delivered (recibo merge) + taskHealth (snapshot).
@MainActor
@Observable
final class AutonomosModel {

    let client: AtlasClient

    var phase: LoadPhase = .loaded
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    /// Ciclos entregues da área efetiva — banner de merge comprovado.
    var delivered: AtlasAutonomosDeliveredResponse?
    /// Saúde global da fila do músculo externo (widgets / snapshot).
    var taskHealth: AtlasAutonomosTaskHealthResponse?
    var lastStartRunReceipt: AtlasAutonomosStartRunResponse?
    var controlError: String?
    /// Catálogo do operador (face Autônomos). Em memória até POST create (§5).
    var operatorUnits: [AutonomosUnit] = []

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    /// Área efetiva para dry-run: seleção explícita, ou a única registrada.
    /// Zero registrada / ambígua → nil (startRun fala o erro, sem no-op silencioso).
    var runTargetArea: AtlasAutonomosArea? {
        if let selected = selectedArea { return selected }
        let registered = areas.filter(\.registered)
        return registered.count == 1 ? registered.first : nil
    }

    /// Face Autônomos = catálogo local (instantâneo). Áreas do loop hidratam
    /// em segundo plano; surfaces globais (taskHealth) alimentam Continuity.
    func load() async {
        clearSelectionProjection()
        phase = .loaded
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
        } catch {
            // Catálogo local funciona sem isto; não derruba a superfície.
        }
        // Uma área registrada: ancora e carrega delivered para o banner.
        if let sole = runTargetArea {
            selectedAreaID = sole.id
        }
        await refreshSelected()
    }

    func clearSelectionProjection() {
        selectedAreaID = nil
        delivered = nil
        taskHealth = nil
    }

    func refreshSelected() async {
        controlError = nil
        do {
            try await loadSelectedDetails()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}

extension AutonomosModel {
    func operatorUnit(id: String) -> AutonomosUnit? {
        operatorUnits.first { $0.id == id }
    }

    @discardableResult
    func createOperatorUnit(name: String, charter: String) -> AutonomosUnit {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCharter = charter.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = AutonomosUnit(
            id: UUID().uuidString,
            name: trimmedName.isEmpty ? "Sem nome" : trimmedName,
            charter: trimmedCharter.isEmpty ? "Escopo ainda sem carta." : trimmedCharter,
            createdAt: Date(),
            paused: true
        )
        operatorUnits.insert(unit, at: 0)
        return unit
    }

    func setOperatorUnitPaused(id: String, paused: Bool) {
        guard let index = operatorUnits.firstIndex(where: { $0.id == id }) else { return }
        operatorUnits[index].paused = paused
    }

    func removeOperatorUnit(id: String) {
        operatorUnits.removeAll { $0.id == id }
    }
}

/// Start dry-run — peel de AutonomosModel.
/// Pause/kill/transfer/decide removidos da face v9 (zero call sites).
extension AutonomosModel {
    /// Um recibo `enqueued` não muda a UI para executando. A confirmação vem
    /// exclusivamente do lease relido em `/live` após o comando.
    /// Sem área efetiva (seleção ou única registrada), falha honesta — nunca no-op.
    func startRun(
        mode: AtlasAutonomosStartRunMode,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard let area = runTargetArea else {
            let registered = areas.filter(\.registered).count
            if registered == 0 {
                controlError = "Nenhuma área registrada no servidor para enfileirar a missão."
            } else {
                controlError = "Há várias áreas registradas — o app ainda não escolhe qual usar neste ensaio."
            }
            return
        }
        controlError = nil
        do {
            let input = AtlasAutonomosStartRunInput(
                mode: mode,
                operatorActor: operatorActor,
                operatorReason: operatorReason,
                focus: area.focus
            )
            lastStartRunReceipt = try await client.startAutonomosRun(area: area.id, input: input)
            // Ancora a seleção no alvo real do dry-run para o próximo refresh.
            selectedAreaID = area.id
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}

extension AutonomosModel {
    /// Surfaces vivas na face v9: delivered (banner merge) + taskHealth (snapshot).
    /// live/cycles/backlog/fleet/digest removidos — zero leitores na casca.
    func loadSelectedDetails() async throws {
        async let taskHealthRequest = client.autonomosTaskHealth()
        if let area = selectedArea ?? runTargetArea {
            async let deliveredRequest = client.autonomosDelivered(area: area.id, focus: area.focus)
            delivered = try? await deliveredRequest
            if selectedAreaID == nil {
                selectedAreaID = area.id
            }
        } else {
            delivered = nil
        }
        taskHealth = try? await taskHealthRequest
        AtlasNativeSnapshotWriter.shared.recordAutonomos(self)
    }

    static func publicMessage(_ error: Error) -> String {
        if let client = error as? AtlasAutonomosClientError {
            switch client {
            case .missingOperatorActor:
                return "Informe quem autoriza esta ação."
            case .missingOperatorReasonForExecute:
                return "Informe o motivo auditável antes de iniciar uma execução."
            case .missingFindingHash:
                return "Escolha uma evidência ou finding antes de registrar a decisão."
            case .missingRationaleForHighRiskAccept:
                return "Aceites de risco alto exigem uma justificativa auditável."
            case .missingTransferReason:
                return "Informe o motivo auditável antes de transferir a missão."
            case .missingRevertReason:
                return "Informe o motivo auditável antes de reverter um ciclo."
            }
        }
        if let api = error as? AtlasApiError { return api.message }
        // Triagem honesta: contrato divergente não pode se esconder atrás de
        // "fora de alcance" (lição do decode do backlog, 2026-07-17).
        if error is DecodingError {
            return "O servidor respondeu num formato que o app não reconhece — contrato divergente; atualize o app."
        }
        if let url = error as? URLError {
            switch url.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Sem conexão — verifique o Wi-Fi ou a VPN do Atlas."
            case .timedOut:
                return "O servidor demorou demais para responder — tente de novo."
            case .cannotConnectToHost, .cannotFindHost:
                return "Não foi possível alcançar o Mac — o atlas-server está de pé?"
            default: break
            }
        }
        return "Não foi possível atualizar o estado do Autônomos agora."
    }
}
