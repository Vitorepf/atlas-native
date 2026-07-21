import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeModel {

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: LoadPhase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?
    private(set) var heal: AtlasCodeHealResponse?
    private(set) var week: AtlasCodeWeek?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    /// Troca in-place — a casca não remonta a NavigationStack.
    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        graph = nil
        violations = nil
        heal = nil
        week = nil
        spineHashes = []
        undoError = nil
    }

    func load(before: String? = nil) async {
        let requested = repo
        phase = .loading
        do {
            // Grafo primeiro: a tela ganha mapa sem esperar heal/week/scan.
            let graph = try await client.getCodeGraph(repo: requested, before: before)
            guard repo == requested else { return }
            self.graph = graph
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.trunkHead)
            phase = .loaded

            async let violationsTask = client.getCodeViolations(repo: requested)
            async let healTask = client.getCodeHealTick(repo: requested)
            async let weekTask = client.getCodeWeek(repo: requested)
            let nextViolations = try? await violationsTask
            let nextHeal = try? await healTask
            let nextWeek = try? await weekTask
            guard repo == requested else { return }
            violations = nextViolations
            heal = nextHeal
            week = nextWeek
            AtlasNativeSnapshotWriter.shared.recordCodeWeek(week)
        } catch {
            guard repo == requested else { return }
            phase = .failed(String(describing: error))
        }
    }

    func undoLastHeal() async {
        guard let id = heal?.healId else { return }
        do {
            _ = try await client.undoCodeHeal(id: id, repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            // O veto muda o mundo: o mapa tem de contar a verdade nova.
            graph = try? await client.getCodeGraph(repo: repo)
            violations = try? await client.getCodeViolations(repo: repo)
        } catch {
            // O veto FALHOU (rede, 500) — e apagar o recibo aqui era esconder
            // exatamente o que o operador tentava desfazer: a folha sumia, ele
            // ficava sem saber se o undo pegou nem como tentar de novo. Falha de
            // veto mantém o recibo na tela; a cura ainda está lá para ser
            // vetada. Silêncio de falha não pode apagar a única ação humana
            // desta tela.
            undoError = "não consegui desfazer agora — a cura continua aqui, tente de novo."
        }
    }

    /// Última falha do veto, para a folha do recibo dizer que o undo não pegou.
    /// `nil` = sem erro pendente; a folha não inventa alarme.
    private(set) var undoError: String?

    /// A espinha inteira, calculada UMA vez por grafo — não uma travessia por
    /// nó, que seria O(n²) numa lista que rola.
    var spineHashes: Set<String> = []
}
