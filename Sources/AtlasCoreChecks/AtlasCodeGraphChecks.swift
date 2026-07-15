import Foundation
import AtlasCore

public func runAtlasCodeGraphChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "schema_version":"atlas.code.graph.v1",
      "repo":"atlas-server",
      "generated_at":"2026-07-15T05:00:00Z",
      "head":"9a06fd4c56",
      "default_branch":"main",
      "nodes":[{"hash":"9a06fd4c56","parents":["4b2b61f974","7c1e8d2a90"],"refs":["HEAD -> main","origin/main"],"author_name":"Vitor Freire","author_email":"vitor@example.test","authored_at":1784316000,"message":"feat(brain): council_review por membro"}],
      "worktrees":[{"path":"/Users/vitor/worktrees/atlas","branch":"main","head":"9a06fd4c56"}],
      "pagination":{"limit":200,"before":null,"has_more":false},
      "cache":{"strategy":"refs_fingerprint","refs_fingerprint":"abc","invalidated":false}
    }
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let decoded = try? decoder.decode(AtlasCodeGraphResponse.self, from: Data(json.utf8))

    check("grafo C22 preserva o hash e os pais reais", decoded?.nodes.first?.hash == "9a06fd4c56" && decoded?.nodes.first?.parents.count == 2)
    check("grafo C22 preserva autor e refs", decoded?.nodes.first?.authorEmail == "vitor@example.test" && decoded?.nodes.first?.refs.first == "HEAD -> main")

    // A mensagem do commit é a manchete da tela: sem ela, a linha não existe.
    check("grafo C22 traz a mensagem do commit verbatim", decoded?.nodes.first?.message == "feat(brain): council_review por membro")
    let semMensagem = json.replacingOccurrences(of: ",\"message\":\"feat(brain): council_review por membro\"", with: "")
    let legado = try? decoder.decode(AtlasCodeGraphResponse.self, from: Data(semMensagem.utf8))
    check("grafo sem mensagem decodifica com ausência honesta", legado != nil && legado?.nodes.first?.message == nil)

    // Gramática de cor: estado, nunca autor nem tipo de commit.
    if let node = decoded?.nodes.first {
        check("nó com ref da default branch é 'na main'", node.isOnDefaultBranch("main") == true)
        check("nó não é 'na main' quando a default branch é outra", node.isOnDefaultBranch("develop") == false)
        check("gramática: sem violação e na main → onMain", AtlasCodeGraphState.state(for: node, defaultBranch: "main", violatingHashes: [], healedHashes: []) == .onMain)
        check("gramática: hash em violação → violating", AtlasCodeGraphState.state(for: node, defaultBranch: "main", violatingHashes: ["9a06fd4c56"], healedHashes: []) == .violating)
        check("gramática: curado vence violação", AtlasCodeGraphState.state(for: node, defaultBranch: "main", violatingHashes: ["9a06fd4c56"], healedHashes: ["9a06fd4c56"]) == .healed)
        check("gramática: fora da main sem regra → history", AtlasCodeGraphState.state(for: node, defaultBranch: "develop", violatingHashes: [], healedHashes: []) == .history)
    } else {
        check("gramática de cor exige nó decodificado", false)
    }
    check("grafo C22 preserva worktree sem inventar estado", decoded?.worktrees.first?.branch == "main" && decoded?.worktrees.first?.head == "9a06fd4c56")
    check("grafo C22 preserva paginação/cache", decoded?.pagination.limit == 200 && decoded?.cache.invalidated == false)
    check("curva do grafo usa midpoint com tangentes verticais", AtlasCodeGraphGeometry.midpointPath(fromX: 24, fromY: 10, toX: 56, toY: 50) == "M 24.0,10.0 C 24.0,30.0 56.0,30.0 56.0,50.0")

    let unknownSchema = json.replacingOccurrences(of: "atlas.code.graph.v1", with: "atlas.code.graph.v2")
    check("schema de grafo desconhecido falha fechado", (try? decoder.decode(AtlasCodeGraphResponse.self, from: Data(unknownSchema.utf8))) == nil)

    let provenanceJSON = """
    {"schema_version":"atlas.code.provenance.v1","repo":"atlas-native","hash":"d0a65d0",
     "commit_message":"feat(core): add Atlas Codigo graph projection","author_name":"Vitor Freire",
     "author_email":"vitordsny@gmail.com","authored_at":1784092694,"agent":"voce",
     "operator_quote":"Autonomia > aprovação","gates":["simulator"]}
    """
    let provenance = try? decoder.decode(AtlasCodeProvenance.self, from: Data(provenanceJSON.utf8))
    check("proveniência C23 decodifica identidade real", provenance?.agent == "voce" && provenance?.hash == "d0a65d0")
    check("proveniência C23 mantém ausência de trace", provenance?.traceId == nil && provenance?.operatorQuote == "Autonomia > aprovação")

    let violationsJSON = """
    {"schema_version":"atlas.code.violations.v1","repo":"atlas-server",
     "generated_at":"2026-07-15T05:00:00Z",
     "violations":[{"rule_id":"main_only","target":"feature/cobaia","since":"2026-07-14T00:00:00Z","severity":"high",
       "plan":[{"action":"cite_rule_to_agent","label":"Citar main_only ao agente"}]}],
     "plan":[{"rule_id":"main_only","target":"feature/cobaia","steps":[{"action":"cite_rule_to_agent","label":"Citar main_only ao agente"}]}]}
    """
    let violations = try? decoder.decode(AtlasCodeViolationsResponse.self, from: Data(violationsJSON.utf8))
    check("scanner C24 preserva regra e alvo", violations?.violations.first?.ruleId == "main_only" && violations?.violations.first?.target == "feature/cobaia")
    check("scanner C24 preserva plan executável", violations?.plan.first?.steps.first?.action == "cite_rule_to_agent")
    let unknownViolationsSchema = violationsJSON.replacingOccurrences(of: "atlas.code.violations.v1", with: "atlas.code.violations.v2")
    check("schema de violações desconhecido falha fechado", (try? decoder.decode(AtlasCodeViolationsResponse.self, from: Data(unknownViolationsSchema.utf8))) == nil)

    let healJSON = """
    {"schema_version":"atlas.code.heals.v1","repo":"atlas-server","generated_at":"2026-07-15T05:00:00Z",
     "mode":"observe","violations":[],"plan":[],"step_receipts":[{"step":1,"action":"delete_branch",
     "status":"completed","result":"branch removed","undo_ref":{"branch":"feature/cobaia","head":"abc"},
     "undo_expires_at":"2026-08-14T05:00:00Z"}]}
    """
    let heal = try? decoder.decode(AtlasCodeHealResponse.self, from: Data(healJSON.utf8))
    check("cura C25 preserva recibo e undo", heal?.stepReceipts.first?.action == "delete_branch" && heal?.stepReceipts.first?.undoRef?["branch"] == "feature/cobaia")
    check("cura C25 não oferece aprovação", heal?.stepReceipts.first?.status == "completed" && heal?.mode == "observe")

    let weekJSON = """
    {"schema_version":"atlas.code.week.v1","repo":"atlas-server","window":"2026-07-08..2026-07-15",
     "commits":214,"heals":3,"prevented":5,"waiting_for_you":0,
     "by_agent":{"fable":84,"codex":96,"voce":34,"autonomo:desconhecido":0},
     "notifications":{"enabled":false,"reason":"operator_opt_in"}}
    """
    let week = try? decoder.decode(AtlasCodeWeek.self, from: Data(weekJSON.utf8))
    check("semana E5 preserva números reais e buckets", week?.commits == 214 && week?.byAgent["codex"] == 96)
    check("semana E5 mantém notificações off", week?.notifications.enabled == false)
}
