import Foundation
import AtlasCore

/// Pack de ocasião do Grafo/Código — WAVE-019 + WAVE-020 grammar.
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
        let screenPack = AtlasCodeGraphScreenJudgment.packFacts(
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

        if let trunk = model.graph?.defaultBranch, !trunk.isEmpty {
            facts.append("trunk: \(trunk)")
        } else {
            absences.append("trunk/default_branch não publicado neste load")
        }
        if let head = model.graph?.head, !head.isEmpty {
            facts.append("head: \(String(head.prefix(7)))")
        }
        if let trunkHead = model.graph?.trunkHead, !trunkHead.isEmpty {
            facts.append("trunk_head: \(String(trunkHead.prefix(7)))")
        }

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            facts.append("commits_loaded: \(nodes.count)")
            let violating = nodes.filter { model.state(for: $0) == .violating }.count
            facts.append("sem_retorno_signals: \(violating)")
        } else {
            absences.append("grafo sem nós (load vazio ou ainda carregando)")
        }

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

        switch model.phase {
        case .loading, .idle:
            facts.append("phase: loading")
        case .failed(let message):
            facts.append("phase: failed")
            if !message.isEmpty { facts.append("failure: \(message)") }
        case .loaded:
            facts.append("phase: loaded")
        }

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
