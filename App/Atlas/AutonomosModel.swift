import Foundation
import Observation
import AtlasCore

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
@MainActor
@Observable
final class AutonomosModel {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let client: AtlasClient

    var phase: Phase = .idle
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    var live: AtlasAutonomosLiveResponse?
    var cycles: AtlasAutonomosCyclesResponse?
    var backlog: AtlasAutonomosBacklogResponse?
    var lastControlReceipt: AtlasAutonomosRunControlResponse?
    var controlError: String?

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    /// Primeiro carregamento: lista de instâncias e, em seguida, o conjunto
    /// vivo da área selecionada. Nada é marcado 'rodando' até /live confirmar
    /// que o lock do loop está efetivamente retido.
    func load() async {
        phase = .loading
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
            let preferred = selectedAreaID ?? response.defaultArea
            selectedAreaID = areas.contains(where: { $0.id == preferred })
                ? preferred
                : areas.first?.id
            try await loadSelectedDetails()
            phase = .loaded
        } catch {
            phase = .failed(Self.publicMessage(error))
        }
    }

    func selectArea(_ id: String) async {
        guard areas.contains(where: { $0.id == id }) else { return }
        selectedAreaID = id
        await refreshSelected()
    }

    func refreshSelected() async {
        guard selectedAreaID != nil else {
            await load()
            return
        }
        controlError = nil
        do {
            try await loadSelectedDetails()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    /// Pausar, retomar ou kill só acontece por ação explícita do operador; o
    /// recibo é relido do servidor para a UI nunca assumir que um signal virou
    /// parada de processo antes da próxima fronteira do loop.
    func control(
        _ action: AtlasAutonomosRunAction,
        operatorActor: String,
        reason: String
    ) async {
        guard let area = selectedArea else { return }
        controlError = nil
        do {
            let input = AtlasAutonomosRunControlInput(
                action: action,
                operatorActor: operatorActor,
                reason: reason,
                focus: area.focus
            )
            lastControlReceipt = try await client.controlAutonomosRun(area: area.id, input: input)
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    private func loadSelectedDetails() async throws {
        guard let area = selectedArea else {
            live = nil; cycles = nil; backlog = nil
            return
        }
        async let liveRequest = client.autonomosLive(area: area.id, focus: area.focus)
        async let cyclesRequest = client.autonomosCycles(area: area.id, focus: area.focus)
        async let backlogRequest = client.autonomosBacklog(area: area.id, focus: area.focus)
        let (nextLive, nextCycles, nextBacklog) = try await (liveRequest, cyclesRequest, backlogRequest)
        live = nextLive
        cycles = nextCycles
        backlog = nextBacklog
    }

    private static func publicMessage(_ error: Error) -> String {
        if let api = error as? AtlasApiError { return api.message }
        return "Não foi possível atualizar o estado do Autônomos agora."
    }
}
