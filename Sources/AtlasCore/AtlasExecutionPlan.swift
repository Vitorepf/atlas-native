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
