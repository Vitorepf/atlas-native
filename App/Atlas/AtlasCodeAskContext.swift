import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: CodeAsk Context + Model fused

// MARK: - Context

// MARK: - Host

enum AtlasCodeAskContext {
    static let invite = "pergunte sobre este repositório"

    static var emptySuggestions: [String] { AtlasCodeAskSuggestions.all }

    static func emptyPrompt(focusLegend: String?) -> String {
        if let focusLegend, !focusLegend.isEmpty {
            return "sobre \(focusLegend) — o que você quer saber?"
        }
        return invite
    }

    @MainActor
    static func facts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        graphStateFilter: AtlasCodeGraphStateFilter = .all,
        serverAskFacts: String? = nil,
        provenancePhase: AtlasCodeProvenanceModel.Phase = .idle,
        whyFile: String? = nil,
        whyPhase: LoadPhase = .idle,
        why: AtlasCodeWhy? = nil,
        whyMessage: String? = nil
    ) -> String {
        occasionFacts(
            model: model,
            focusNode: focusNode,
            focusLegend: focusLegend,
            isAnchoring: isAnchoring,
            graphStateFilter: graphStateFilter,
            serverAskFacts: serverAskFacts,
            provenancePhase: provenancePhase,
            whyFile: whyFile,
            whyPhase: whyPhase,
            why: why,
            whyMessage: whyMessage
        )
    }

    @MainActor
    static func occasionFacts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        graphStateFilter: AtlasCodeGraphStateFilter,
        serverAskFacts: String?,
        provenancePhase: AtlasCodeProvenanceModel.Phase = .idle,
        whyFile: String? = nil,
        whyPhase: LoadPhase = .idle,
        why: AtlasCodeWhy? = nil,
        whyMessage: String? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = ["repo: \(model.repo)"]
        var absences: [String] = []

        if let legend = focusLegend?.trimmingCharacters(in: .whitespacesAndNewlines), !legend.isEmpty {
            anchors.append("legend: \(legend)")
        }
        if let node = focusNode {
            let short = String(node.hash.prefix(7))
            anchors.append("commit: \(short)")
            if let message = node.message, !message.isEmpty {
                anchors.append("subject: \(message)")
            }
            let state = model.state(for: node)
            anchors.append("state: \(AtlasCodeGraphJudgment.productWord(for: state))")
            // WAVE-167: commit row + provenance organs for focused node.
            let rowPack = AtlasCodeCommitRowJudgment.packFacts(
                node: node,
                state: state,
                isDimmed: false,
                trunk: model.graph?.defaultBranch,
                ruleId: nil
            )
            facts.append(contentsOf: rowPack.facts)
            absences.append(contentsOf: rowPack.absences)
            let provPack = AtlasCodeProvenanceJudgment.packFacts(
                node: node,
                state: state,
                trunk: model.graph?.defaultBranch,
                phase: provenancePhase,
                ruleId: nil
            )
            facts.append(contentsOf: provPack.facts)
            absences.append(contentsOf: provPack.absences)
        } else if isAnchoring {
            anchors.append("âncora H6 ativa (sem nó de swipe local)")
        }

        // WAVE-167: why/biography organ when sheet target published.
        if let whyFile, !whyFile.isEmpty {
            let whyPack = AtlasCodeWhyJudgment.packFacts(
                file: whyFile,
                phase: whyPhase,
                why: why,
                message: whyMessage
            )
            facts.append(contentsOf: whyPack.facts)
            absences.append(contentsOf: whyPack.absences)
        }

        // WAVE-161: graph screen face organ (loading/failed/empty/ready).
        let failMsg: String? = {
            if case .failed(let m) = model.phase { return m }
            return nil
        }()
        let screenPack = AtlasCodeGraphLoadJudgment.packFacts(
            repo: model.repo,
            phase: model.phase,
            nodeCount: model.graph?.nodes.count ?? 0,
            failMessage: failMsg,
            isAnchoring: isAnchoring
        )
        facts.append(contentsOf: screenPack.facts)
        absences.append(contentsOf: screenPack.absences)

        // WAVE-062: exclusive ask-pill face (invite / anchoring / legend).
        let pill = AtlasCodeAskPillJudgment.packFacts(
            isAnchoring: isAnchoring,
            anchorLegend: focusLegend
        )
        facts.append(contentsOf: pill.facts)
        absences.append(contentsOf: pill.absences)

        // WAVE-187: graph identity (trunk/head/commits/phase).
        let identity = AtlasCodeGraphJudgment.packIdentityFacts(model: model)
        facts.append(contentsOf: identity.facts)
        absences.append(contentsOf: identity.absences)

        // WAVE-028: filter · status · worktrees · slice (same fatia as chips/list).
        let slice = AtlasCodeGraphJudgment.packSliceFacts(model: model, filter: graphStateFilter)
        facts.append(contentsOf: slice.facts)
        absences.append(contentsOf: slice.absences)

        // WAVE-043: exclusive repo health face (scan · heal · week · mirror when host passes).
        let health = AtlasCodeRepoHealthJudgment.packFacts(model: model, mirror: nil)
        facts.append(contentsOf: health.facts)
        absences.append(contentsOf: health.absences)

        // WAVE-048: heal veto face + undo failure honesty.
        let veto = AtlasCodeHealVetoJudgment.packFacts(
            heal: model.heal,
            undoError: model.undoError
        )
        facts.append(contentsOf: veto.facts)
        absences.append(contentsOf: veto.absences)

        absences.append("dual-count obra/branch vs issues não reconciliado na casca (Core §5 se faltar DTO)")
        absences.append("filtro por agente não exposto no pack (sem DTO de filter)")
        absences.append(contentsOf: AtlasCodeGraphJudgment.packCanDoAbsences(hasHealReceipt: model.hasHealReceipt))

        let healthFace = AtlasCodeRepoHealthJudgment.face(model: model, mirror: nil)
        let subject = "repositório \(model.repo) · \(slice.subjectSuffix) · \(healthFace.productWord)"

        return AgenticOccasionPack(
            surface: "code.graph",
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: AtlasCodeGraphJudgment.packCanDo(hasHealReceipt: model.hasHealReceipt),
            appendix: serverAskFacts
        ).render()
    }
}

// MARK: - Model

@Observable
@MainActor
final class AtlasCodeAskModel {
    enum Phase: Equatable {
        case idle
        case answered(AtlasCodeAskResponse)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// Legenda de âncora de swipe/proveniência — mesma voz da pílula e do emptyPrompt.
    /// Presentation-only; não é âncora de resposta git (`anchors` / `anchorNote`).
    private(set) var sheetFocusLegend: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        sheetFocusLegend = nil
    }

    func setSheetFocusLegend(_ legend: String?) {
        let trimmed = legend?.trimmingCharacters(in: .whitespacesAndNewlines)
        sheetFocusLegend = (trimmed?.isEmpty == false) ? trimmed : nil
    }

    /// Os commits que a resposta atual cita. O grafo acende só estes.
    var anchors: Set<String> {
        if case .answered(let response) = phase { return response.anchorSet }
        return []
    }

    /// Verdadeiro quando há resposta apontando para commits: o grafo então
    /// apaga o resto, porque a resposta é o assunto.
    var isAnchoring: Bool { !anchors.isEmpty }

    /// A legenda do recorte: "12 de 43 acesos no grafo".
    ///
    /// Um mapa com 3/4 da história a 0.26 de opacidade e nenhuma frase dizendo
    /// o porquê lê como "é só isso" — que é mentira sobre o repositório. O
    /// servidor calcula `commits_total` e `truncated` exatamente para esta
    /// frase existir, e ela estava escrita e morta: `anchorNote` não tinha um
    /// único chamador no app inteiro. Contrato dos dois lados, faltando o Text.
    var anchorNote: String? {
        if case .answered(let response) = phase { return response.anchorNote }
        return nil
    }

    /// Limpar apaga a âncora de resposta: o grafo volta a mostrar tudo.
    /// Não mexe em `sheetFocusLegend` (swipe) — use `setSheetFocusLegend(nil)`.
    func clear() {
        phase = .idle
    }

    /// Os fatos de um turno da conversa, para o agente ler antes de responder.
    ///
    /// Efeito colateral deliberado: a mesma leitura ancora o grafo. Quando o
    /// card fecha, o mapa atrás já está aceso nos commits que sustentaram a
    /// resposta — perguntar move a topologia, que é o ponto da tela.
    ///
    /// `nil` quando o determinístico não sabe (julgamento não é filtro de git) e
    /// quando a rede cai: o agente responde sem muleta, e falha de rede nunca
    /// vira fato inventado com ar de autoridade.
    ///
    /// `answered` é o que decide se a topologia se move, e a distinção é fina:
    /// - `answered == false` → o git NÃO foi lido (julgamento, ou git mudo).
    ///   A leitura não tem opinião sobre o mapa, então o mapa fica como está.
    ///   Sem esta guarda, "explica melhor" — a coisa mais natural do mundo num
    ///   card de conversa — apagava em silêncio a resposta anterior, e a tese
    ///   da tela sobrevivia a exatamente um turno.
    /// - `answered == true` com zero commits → o git FOI lido e não há o que
    ///   acender ("nada mudou hoje"). Aí a âncora morre mesmo: a leitura nova é
    ///   a verdade nova, e segurar o mapa velho seria mentir com mapa.
    ///
    /// É a mesma guarda de `AtlasCodeFacts.block`: quem não leu não afirma.
    func facts(for question: String) async -> String? {
        guard let response = try? await client.askCode(repo: repo, question: question, mode: .facts),
              response.answered
        else { return nil }
        phase = .answered(response)
        return AtlasCodeFacts.block(from: response)
    }
}
