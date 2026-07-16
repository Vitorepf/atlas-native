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
    {"schema_version":"atlas.code.provenance.v2","repo":"atlas-native","hash":"d0a65d0",
     "commit_message":"feat(core): add Atlas Codigo graph projection",
     "commit_body":"O mapa vem primeiro: a mensagem é a manchete.","author_name":"Vitor Freire",
     "author_email":"vitordsny@gmail.com","authored_at":1784092694,"agent":"voce",
     "files":[
       {"path":"Sources/AtlasCore/AtlasCodeGraph.swift","status":"modified","additions":48,"deletions":12,"renamed_from":null},
       {"path":"Sources/AtlasCore/AtlasCodeIssue.swift","status":"added","additions":56,"deletions":0,"renamed_from":null},
       {"path":"App/Assets/icon.png","status":"added","additions":null,"deletions":null,"renamed_from":null},
       {"path":"Sources/AtlasCore/New.swift","status":"renamed","additions":3,"deletions":1,"renamed_from":"Sources/AtlasCore/Old.swift"}],
     "operator_quote":"Autonomia > aprovação","gates":["simulator"]}
    """
    let provenance = try? decoder.decode(AtlasCodeProvenance.self, from: Data(provenanceJSON.utf8))
    check("proveniência C23 decodifica identidade real", provenance?.agent == "voce" && provenance?.hash == "d0a65d0")
    check("proveniência C23 mantém ausência de trace", provenance?.traceId == nil && provenance?.operatorQuote == "Autonomia > aprovação")

    // A folha precisa dizer O QUE mudou: descrição + arquivos com verbo.
    check("proveniência C23 carrega a descrição do commit", provenance?.commitBody == "O mapa vem primeiro: a mensagem é a manchete.")
    check("proveniência C23 lista os arquivos com verbo", provenance?.files.count == 4 && provenance?.files.first?.status == .modified)
    check("proveniência C23 preserva rename com origem", provenance?.files.last?.status == .renamed && provenance?.files.last?.renamedFrom == "Sources/AtlasCore/Old.swift")
    // Binário: ausência de contagem jamais vira 0.
    check("proveniência C23 diz ausência de contagem em binário", provenance?.files[2].additions == nil && provenance?.files[2].deletions == nil)
    // Total derivado: binário conta como arquivo e soma zero linha.
    check("proveniência C23 soma o diff sem inventar binário", provenance?.diffHeadline == "4 arquivos · +107 \u{2212}13")
    check("proveniência C23 separa nome e pasta do arquivo", provenance?.files.first?.fileName == "AtlasCodeGraph.swift" && provenance?.files.first?.directory == "Sources/AtlasCore")

    let unknownStatusJSON = provenanceJSON.replacingOccurrences(of: "\"status\":\"modified\"", with: "\"status\":\"submoduled\"")
    let unknownStatus = try? decoder.decode(AtlasCodeProvenance.self, from: Data(unknownStatusJSON.utf8))
    // Verbo novo do Git não derruba a folha inteira: aparece como desconhecido.
    check("proveniência C23 sobrevive a verbo de arquivo desconhecido", unknownStatus?.files.first?.status == .unknown)

    let singleFileJSON = """
    {"schema_version":"atlas.code.provenance.v2","repo":"atlas-native","hash":"d0a65d0",
     "commit_message":"fix: typo","author_name":"Vitor Freire","author_email":"vitordsny@gmail.com",
     "authored_at":1784092694,"agent":"voce","files":[{"path":"README.md","status":"modified","additions":1,"deletions":1,"renamed_from":null}]}
    """
    let singleFile = try? decoder.decode(AtlasCodeProvenance.self, from: Data(singleFileJSON.utf8))
    check("proveniência C23 fala português no singular", singleFile?.diffHeadline == "1 arquivo · +1 \u{2212}1")
    check("proveniência C23 admite commit sem descrição", singleFile?.commitBody == nil)

    let emptyDiffJSON = singleFileJSON.replacingOccurrences(of: "\"files\":[{\"path\":\"README.md\",\"status\":\"modified\",\"additions\":1,\"deletions\":1,\"renamed_from\":null}]", with: "\"files\":[]")
    let emptyDiff = try? decoder.decode(AtlasCodeProvenance.self, from: Data(emptyDiffJSON.utf8))
    // Sem arquivo não há manchete de diff — ausência é dita, não preenchida.
    check("proveniência C23 cala quando não há arquivo", emptyDiff?.files.isEmpty == true && emptyDiff?.diffHeadline == nil)

    let unknownProvenanceSchema = provenanceJSON.replacingOccurrences(of: "atlas.code.provenance.v2", with: "atlas.code.provenance.v1")
    check("schema de proveniência antigo falha fechado", (try? decoder.decode(AtlasCodeProvenance.self, from: Data(unknownProvenanceSchema.utf8))) == nil)

    // O corpo do commit foi escrito para o terminal (quebra em 72 colunas).
    // A folha é prosa: a quebra acidental some, a quebra com forma fica.
    let hardWrapped = """
    Erro de MODELO apontado pelo operador: 'Atlas' e 'Blackink' apareciam
    como repositórios quebrados.

    O que muda:
    - pasta vira pasta, não repo quebrado
    - recentes viram atalho, não cópia

    Co-Authored-By: Atlas <atlas@local>
    """
    let reflowed = AtlasCodeCommitBody.prose(hardWrapped)
    check(
        "corpo do commit reflui a quebra de 72 colunas em prosa",
        reflowed.hasPrefix("Erro de MODELO apontado pelo operador: 'Atlas' e 'Blackink' apareciam como repositórios quebrados.")
    )
    check("corpo do commit preserva o parágrafo em branco", reflowed.contains("\n\nO que muda:\n\n- pasta vira pasta"))
    check("corpo do commit preserva item de lista em linha própria", reflowed.contains("- pasta vira pasta, não repo quebrado\n\n- recentes viram atalho, não cópia"))
    // Trailer é encanamento do Git — e nomeia o motor. Não sobe à superfície.
    check("corpo do commit não vaza trailer do Git", !reflowed.contains("Co-Authored-By"))
    check("corpo do commit termina na prosa, não no encanamento", reflowed.hasSuffix("- recentes viram atalho, não cópia"))
    check("corpo do commit não inventa texto quando está vazio", AtlasCodeCommitBody.prose("") == "")
    // Um corpo que é só trailer não vira bloco vazio na tela.
    check("corpo só de trailer some inteiro", AtlasCodeCommitBody.prose("Co-Authored-By: Atlas <atlas@local>") == "")
    // Travessão abre prosa; só o hífen ASCII com espaço marca item de lista.
    check(
        "corpo do commit não confunde travessão com lista",
        AtlasCodeCommitBody.prose("a verdade é grave\n— e o portão recusou") == "a verdade é grave — e o portão recusou"
    )
    // Dois-pontos no meio da frase não é trailer: prosa continua prosa.
    check(
        "corpo do commit não confunde frase com trailer",
        AtlasCodeCommitBody.prose("Na tela: bloco vermelho no topo") == "Na tela: bloco vermelho no topo"
    )
    // Código indentado é forma: a quebra dele é significado.
    check(
        "corpo do commit preserva código indentado",
        AtlasCodeCommitBody.prose("rode:\n\n    make device\n    make build").contains("make device\n\nmake build")
    )

    // O servidor fala slug; a superfície fala a língua do operador.
    check("proveniência C23 traduz o agente para português", provenance?.agentLabel == "você")

    // H6 · a pílula. Resposta é fato com âncora, não bolha de conversa.
    let askJSON = """
    {"schema_version":"atlas.code.ask.v1","repo":"atlas-native","question":"o que mudou hoje?",
     "intent":"changes","answered":true,"answer":"22 commits hoje — 22 de Vitor Freire.",
     "commits":["9a06fd4c56","d0a65d0aa1"],"truncated":false,
     "evidence":[],"source":"graph",
     "window":{"kind":"today","since":1784084400,"timezone":"America/Sao_Paulo"}}
    """
    let ask = try? decoder.decode(AtlasCodeAskResponse.self, from: Data(askJSON.utf8))
    check("pílula H6 decodifica a resposta ancorada", ask?.intent == .changes && ask?.answered == true)
    check("pílula H6 entrega as âncoras que o grafo acende", ask?.anchorSet == ["9a06fd4c56", "d0a65d0aa1"])
    // A janela viaja junto: "hoje" é uma afirmação sobre o tempo, conferível.
    check("pílula H6 diz o recorte de tempo que usou", ask?.window?.timezone == "America/Sao_Paulo" && ask?.window?.since == 1784084400)

    let unknownAskJSON = """
    {"schema_version":"atlas.code.ask.v1","repo":"atlas-native","question":"foi uma boa ideia?",
     "intent":"philosophy","answered":false,"answer":"essa pergunta precisa do cérebro.",
     "source":"graph"}
    """
    let unknownAsk = try? decoder.decode(AtlasCodeAskResponse.self, from: Data(unknownAskJSON.utf8))
    // Intenção nova do servidor não derruba a tela: cai no caminho do "não sei".
    check("pílula H6 sobrevive a intenção desconhecida", unknownAsk?.intent == .unknown)
    // Ausência de resposta é DITA. Este é o defeito original da pílula: ela
    // prometia sem cumprir.
    check("pílula H6 admite quando não sabe, sem âncora falsa", unknownAsk?.answered == false && unknownAsk?.commits.isEmpty == true && unknownAsk?.window == nil)

    let unknownAskSchema = askJSON.replacingOccurrences(of: "atlas.code.ask.v1", with: "atlas.code.ask.v2")
    check("schema de pergunta desconhecido falha fechado", (try? decoder.decode(AtlasCodeAskResponse.self, from: Data(unknownAskSchema.utf8))) == nil)

    // Sugestão que a pílula não sabe responder é promessa falsa — o defeito
    // original dela. Que CADA sugestão roteia para intenção real quem prova é
    // AtlasCodeQuestionRouterTest::test_every_pill_suggestion_routes_to_a_real_intent,
    // no servidor, onde o roteador mora. Aqui só se prova o que daqui se vê.
    check("pílula H6 tem sugestão para ensinar o próprio poder", AtlasCodeAskSuggestions.all.count >= 3 && AtlasCodeAskSuggestions.all.allSatisfy { !$0.isEmpty })

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

    // M3 v2 · o workspace real: pastas de produto + recentes. Pasta NÃO é
    // repositório quebrado — e a tela fala português.
    let workspaceJSON = """
    {"schema_version":"atlas.code.repos.v2","generated_at":"2026-07-15T14:00:00Z",
     "workspace_root":"/Users/vitorepf/develop",
     "recents":[
       {"slug":"atlas-server","name":"Atlas Server","path":"/d/Atlas/atlas-server","folder":"Atlas","last_commit_at":1784316000},
       {"slug":"blackink-website","name":"Blackink Website","path":"/d/blackink/blackink-website","folder":"blackink","last_commit_at":1784200000}],
     "folders":[
       {"slug":"Atlas","name":"Atlas","repositories":2,"last_commit_at":1784316000,
        "repos":[{"slug":"atlas-server","name":"Atlas Server","path":"/d/Atlas/atlas-server","folder":"Atlas","last_commit_at":1784316000},
                 {"slug":"atlas-desktop","name":"Atlas Desktop","path":"/d/Atlas/atlas-desktop","folder":"Atlas","last_commit_at":null}]},
       {"slug":"blackink","name":"Blackink","repositories":1,"last_commit_at":1784200000,
        "repos":[{"slug":"blackink-website","name":"Blackink Website","path":"/d/blackink/blackink-website","folder":"blackink","last_commit_at":1784200000}]}],
     "loose":[{"slug":"vitorepf-site","name":"Vitorepf Site","path":"/d/vitorepf-site","folder":null,"last_commit_at":1784000000}]}
    """
    let workspace = try? decoder.decode(AtlasCodeWorkspaceResponse.self, from: Data(workspaceJSON.utf8))
    check("workspace v2 decodifica pastas de produto", workspace?.folders.count == 2 && workspace?.folders.first?.name == "Atlas")
    check("workspace v2 separa recentes", workspace?.recents.count == 2 && workspace?.recents.first?.slug == "atlas-server")
    check("workspace v2 preserva repo solto", workspace?.loose.first?.slug == "vitorepf-site" && workspace?.loose.first?.folder == nil)
    check("pasta guarda seus repositórios sem remover os recentes", workspace?.folders.first?.repos.count == 2)
    check("contagem real de repositórios", workspace?.repositoryCount == 4)
    check("repo sem história mantém ausência", workspace?.folders.first?.repos.last?.lastCommitAt == nil)
    check("sem data, nenhuma idade é inventada", AtlasCodeAge.short(from: nil) == nil)

    // A tela fala português: id de regra nunca chega ao operador.
    let issues = [
        AtlasCodeIssue(ruleId: "orphan_branch", count: 4, severity: "high", oldestDays: 9),
        AtlasCodeIssue(ruleId: "obra_return_deadline", count: 17, severity: "medium", oldestDays: 22),
        AtlasCodeIssue(ruleId: "worktree_allowlist", count: 1, severity: "medium", oldestDays: nil),
    ]
    check("frase humana: branch abandonada", issues[0].headline == "4 branches abandonadas")
    check("frase humana: obra que não voltou", issues[1].headline == "17 obras nunca voltaram à main")
    check("singular resolvido", issues[2].headline == "1 worktree fora do lugar")
    check("idade medida vira nota humana", issues[1].ageNote == "a mais antiga há 22 dias")
    check("sem idade medida, nenhuma nota", issues[2].ageNote == nil)
    let visivel = issues.map { $0.headline + ($0.ageNote ?? "") }.joined(separator: " ")
    check("nenhum id de regra vaza para a tela", !visivel.contains("_"))

    let weekJSON = """
    {"schema_version":"atlas.code.week.v1","repo":"atlas-server","window":"2026-07-08..2026-07-15",
     "commits":214,"heals":3,"prevented":5,"waiting_for_you":0,
     "by_agent":{"fable":84,"codex":96,"voce":34,"autonomo:desconhecido":0},
     "notifications":{"enabled":false,"reason":"operator_opt_in"}}
    """
    let week = try? decoder.decode(AtlasCodeWeek.self, from: Data(weekJSON.utf8))
    check("semana E5 preserva números reais e buckets", week?.commits == 214 && week?.byAgent["codex"] == 96)
    check("semana E5 mantém notificações off", week?.notifications.enabled == false)

    // A ESPINHA: a lei central da tela (dourado = na main) dependia da ref, e o
    // git decora só a PONTA. Medido no atlas-server real: dos 200 commits da
    // janela, 197 estavam na main e a tela pintava 6. A espinha é alcance a
    // partir do head pelos pais — não decoração.
    func no(_ hash: String, parents: [String], refs: [String] = []) -> AtlasCodeGraphNode? {
        let refsJson = refs.map { "\"\($0)\"" }.joined(separator: ",")
        let parentsJson = parents.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {"hash":"\(hash)","parents":[\(parentsJson)],"refs":[\(refsJson)],
         "author_name":"Vitor","author_email":"v@x.test","authored_at":1784316000,"message":"x"}
        """
        let d = JSONDecoder(); d.keyDecodingStrategy = atlasSnakeKeyDecoding
        return try? d.decode(AtlasCodeGraphNode.self, from: Data(json.utf8))
    }

    // ponta → pai → avô: só a ponta tem ref, e os três estão na main.
    let ponta = no("aaa", parents: ["bbb"], refs: ["HEAD -> main"])
    let pai = no("bbb", parents: ["ccc"])
    let avo = no("ccc", parents: [])
    let solto = no("zzz", parents: [])
    let cadeia = [ponta, pai, avo, solto].compactMap { $0 }

    let espinha = AtlasCodeGraphState.spine(nodes: cadeia, head: "aaa")
    check("a espinha alcança o ancestral sem ref — o git decora só a ponta", espinha == ["aaa", "bbb", "ccc"])
    check("commit fora do alcance do head não entra na espinha", !espinha.contains("zzz"))

    check(
        "o pai sem ref é DOURADO: ele está na main",
        AtlasCodeGraphState.state(for: pai!, defaultBranch: "main", violatingHashes: [], healedHashes: [], spineHashes: espinha) == .onMain
    )
    check(
        "o commit fora da main continua história",
        AtlasCodeGraphState.state(for: solto!, defaultBranch: "main", violatingHashes: [], healedHashes: [], spineHashes: espinha) == .history
    )
    check(
        "violação vence a espinha: a exceção é o que o operador precisa ver",
        AtlasCodeGraphState.state(for: pai!, defaultBranch: "main", violatingHashes: ["bbb"], healedHashes: [], spineHashes: espinha) == .violating
    )

    // Ciclo não existe em git, mas merge faz o mesmo nó ser alcançado por dois
    // caminhos: a travessia não pode entrar em loop nem contar duas vezes.
    let merge = [no("m", parents: ["a", "b"]), no("a", parents: ["base"]), no("b", parents: ["base"]), no("base", parents: [])].compactMap { $0 }
    check("merge: os dois caminhos chegam na base sem loop", AtlasCodeGraphState.spine(nodes: merge, head: "m") == ["m", "a", "b", "base"])

    // Sem head (contrato antigo), errar para o lado de NÃO afirmar.
    check("sem head, a espinha é vazia — nunca um chute", AtlasCodeGraphState.spine(nodes: cadeia, head: nil).isEmpty)
    check(
        "sem espinha, a tela volta à ref: pinta menos, nunca pinta errado",
        AtlasCodeGraphState.state(for: ponta!, defaultBranch: "main", violatingHashes: [], healedHashes: [], spineHashes: []) == .onMain
            && AtlasCodeGraphState.state(for: pai!, defaultBranch: "main", violatingHashes: [], healedHashes: [], spineHashes: []) == .history
    )

    // Pai fora da janela paginada é normal: a travessia para, sem drama.
    check(
        "pai fora da janela não quebra a travessia",
        AtlasCodeGraphState.spine(nodes: [no("x", parents: ["forade"])].compactMap { $0 }, head: "x") == ["x", "forade"]
    )
}
