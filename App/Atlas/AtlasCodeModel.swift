import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeModel {

    let client: AtlasClient
    let repo: String
    private(set) var phase: LoadPhase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?
    private(set) var heal: AtlasCodeHealResponse?
    private(set) var week: AtlasCodeWeek?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    func load(before: String? = nil) async {
        phase = .loading
        do {
            let graph = try await client.getCodeGraph(repo: repo, before: before)
            self.graph = graph
            // A espinha nasce da ponta da TRUNK e desce pelos pais.
            //
            // Duas coisas que pareciam uma: o git decora só a ponta (por isso a
            // travessia), e `head` é onde o OPERADOR está, não a trunk (por
            // isso `trunkHead`). Traçar do `head` numa obra pintaria a obra
            // inteira de dourado — a exceção vestida de norma. Sem trunk, sem
            // espinha: pinta menos, nunca pinta errado.
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.trunkHead)
            // A stale or unavailable scan must not hide a valid topology.
            violations = try? await client.getCodeViolations(repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            week = try? await client.getCodeWeek(repo: repo)
            AtlasNativeSnapshotWriter.shared.recordCodeWeek(week)
            phase = .loaded
        } catch {
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
