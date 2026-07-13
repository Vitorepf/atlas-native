import Foundation

/// Projeção pública do `metadata.execution_plan` criado pelo Atlas Terminal.
///
/// O plano responde "qual é a obra e quais provas a fecham". Ele não tenta
/// adivinhar uma porcentagem nem materializa raciocínio do provider: só um
/// evento verificável do servidor poderá acrescentar progresso no futuro.
public struct AtlasExecutionPlan: Sendable, Equatable {
    public struct Agent: Sendable, Equatable, Identifiable {
        public let id: String
        public let title: String
    }

    public struct Tool: Sendable, Equatable, Identifiable {
        public let id: String
        public let label: String
    }

    public struct QualityGate: Sendable, Equatable, Identifiable {
        public let id: String
        public let label: String
    }

    public struct Step: Sendable, Equatable, Identifiable {
        public let id: String
        /// Chave pública correspondente ao `metadata.checkpoint` do ledger.
        public let checkpoint: String
        public let title: String
    }

    public struct Progress: Sendable, Equatable {
        /// Posição humana, 1-based, do último checkpoint realmente observado.
        public let current: Int
        public let total: Int
        public let title: String
        public let isTerminal: Bool
    }

    public let workflow: String
    public let title: String
    public let agents: [Agent]
    public let tools: [Tool]
    public let qualityGates: [QualityGate]
    public let steps: [Step]
    public let requiresHumanConfirmation: Bool

    public init?(metadata: JSONObject?) {
        guard let raw = metadata?["execution_plan"], case .object(let values) = raw,
              let workflow = values["workflow"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !workflow.isEmpty,
              let rawAgents = values["agents"]?.stringArray, !rawAgents.isEmpty,
              let rawTools = values["tools_allowed"]?.stringArray,
              let rawGates = values["quality_gates"]?.stringArray, !rawGates.isEmpty
        else { return nil }

        self.workflow = workflow
        self.title = Self.workflowTitle(workflow)
        self.agents = rawAgents.map { Agent(id: $0, title: Self.agentTitle($0)) }
        self.tools = rawTools.map { Tool(id: $0, label: Self.toolTitle($0)) }
        self.qualityGates = rawGates.map { QualityGate(id: $0, label: Self.gateTitle($0)) }
        self.steps = Self.steps(from: values["steps"])
        self.requiresHumanConfirmation = values["requires_human_confirmation"]?.boolValue ?? false
    }

    /// Calcula o estado visual somente a partir dos checkpoints que o Gateway
    /// e o Worker registraram. Ausência de `steps` ou de evento continua sendo
    /// ausência de progresso, não uma barra em 0% fabricada.
    public func progress(events: [AtlasAiStreamEvent], traceStatus: String) -> Progress? {
        guard !steps.isEmpty else { return nil }
        // O servidor gera checkpoints únicos; ainda assim, um payload malformado
        // não pode derrubar a conversa. O primeiro declarado vence.
        var checkpointIndex: [String: Int] = [:]
        for (index, step) in steps.enumerated() where checkpointIndex[step.checkpoint] == nil {
            checkpointIndex[step.checkpoint] = index
        }
        let observed = events
            .sorted { $0.sequence < $1.sequence }
            .compactMap { event -> Int? in
                guard let checkpoint = event.metadata["checkpoint"]?.stringValue else { return nil }
                return checkpointIndex[checkpoint]
            }
        let terminal = ["succeeded", "completed"].contains(traceStatus.lowercased())
        if terminal, let last = steps.indices.last {
            return Progress(current: last + 1, total: steps.count, title: steps[last].title, isTerminal: true)
        }
        guard let index = observed.last else { return nil }
        return Progress(current: index + 1, total: steps.count, title: steps[index].title, isTerminal: false)
    }
}

public extension AtlasAiTrace {
    /// Valor calculado do envelope que já sobrevive a stream, polling e relaunch.
    /// O DTO do trace permanece dono do wire bruto; esta extensão é o seam
    /// seguro consumido por `ConversationModel` e pelas Views.
    var executionPlan: AtlasExecutionPlan? { AtlasExecutionPlan(metadata: metadata) }

    var executionProgress: AtlasExecutionPlan.Progress? {
        executionPlan?.progress(events: streamEvents ?? [], traceStatus: status)
    }
}

private extension JSONValue {
    var stringArray: [String]? {
        guard case .array(let values) = self else { return nil }
        let strings = values.compactMap(\.stringValue)
        return strings.count == values.count ? strings : nil
    }
}

private extension AtlasExecutionPlan {
    static func steps(from value: JSONValue?) -> [Step] {
        guard case .array(let values) = value else { return [] }
        return values.compactMap { value in
            guard case .object(let object) = value,
                  let id = object["id"]?.stringValue,
                  let checkpoint = object["checkpoint"]?.stringValue,
                  let title = object["title"]?.stringValue,
                  !id.isEmpty, !checkpoint.isEmpty, !title.isEmpty
            else { return nil }
            return Step(id: id, checkpoint: checkpoint, title: title)
        }
    }

    static func workflowTitle(_ workflow: String) -> String {
        switch workflow {
        case "plan_execute_test_review_summarize": return "Planejar, executar e comprovar"
        case "reproduce_localize_patch_regress": return "Reproduzir, corrigir e testar"
        case "read_diff_find_risks_recommend": return "Revisar mudanças e riscos"
        case "plan_source_extract_synthesize": return "Pesquisar e sintetizar"
        case "frame_options_tradeoffs_recommend": return "Avaliar opções e recomendar"
        case "extract_classify_validate_store_candidate": return "Extrair e validar memória"
        case "frame_plan_risks_next_step": return "Definir plano e próximos passos"
        case "direct_answer_with_context": return "Responder com contexto"
        default: return "Plano de execução"
        }
    }

    static func agentTitle(_ value: String) -> String {
        switch value {
        case "planner": return "Planejador"
        case "executor": return "Executor"
        case "reviewer": return "Revisor"
        case "debugger": return "Depurador"
        case "researcher": return "Pesquisador"
        case "source_checker": return "Verificador de fontes"
        case "synthesizer": return "Sintetizador"
        case "decision_advisor": return "Conselheiro de decisão"
        case "skeptic": return "Revisor crítico"
        case "memory_writer": return "Curador de memória"
        case "evaluator": return "Avaliador"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    static func toolTitle(_ value: String) -> String {
        switch value {
        case "semantic_search": return "Busca semântica"
        case "session.search": return "Busca na sessão"
        case "repo_context": return "Contexto do projeto"
        case "git_diff": return "Diferenças do Git"
        case "source_retrieval": return "Recuperação de fontes"
        case "memory_schema": return "Esquema de memória"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    static func gateTitle(_ value: String) -> String {
        switch value {
        case "answer_grounded_in_context_or_lacuna_declared": return "Resposta fundamentada ou lacuna declarada"
        case "findings_before_summary": return "Achados antes do resumo"
        case "risks_and_missing_tests_checked": return "Riscos e testes ausentes verificados"
        case "diff_summary_required": return "Resumo das mudanças"
        case "tests_or_not_run_reason_required": return "Testes ou motivo registrado"
        case "sources_required_when_claiming_facts": return "Fontes exigidas para fatos"
        case "tradeoffs_and_reversibility_required": return "Trade-offs e reversibilidade explícitos"
        case "human_authorship_preserved": return "Autoria humana preservada"
        case "memory_origin_scope_confidence_required": return "Origem, escopo e confiança registrados"
        case "human_confirmation_required": return "Confirmação humana necessária"
        default: return value.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
