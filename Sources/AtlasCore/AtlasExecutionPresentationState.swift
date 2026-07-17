import Foundation

/// Estado público e acionável de uma execução. O servidor o publica de forma
/// explícita; o cliente não infere atenção, falha ou replanejamento a partir de
/// texto do modelo, logs ou animações.
public struct AtlasExecutionPresentationState: Sendable, Equatable {
    public enum Kind: String, Sendable, Equatable {
        case attentionRequired = "attention_required"
        case replanning
        case awaitingExternal = "awaiting_external"
        case recovering
        case failed
        case completed
    }

    public enum ActionStyle: String, Sendable, Equatable {
        case primary
        case secondary
        case destructive
    }

    public struct Action: Sendable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let style: ActionStyle
    }

    /// Relógio público da execução. O servidor acumula somente o tempo ativo
    /// e declara cada marco de pausa/retomada; nenhuma superfície precisa
    /// deduzir ou reconstruir pausas a partir de rede ou animação local.
    public struct Timer: Sendable, Equatable {
        public enum Timing: String, Sendable, Equatable {
            case running
            case paused
            case finished
        }

        public let elapsedActiveMilliseconds: Int
        public let timing: Timing
        public let runningSince: Date?
        public let pausedAt: Date?
        public let finishedAt: Date?
    }

    public let kind: Kind
    public let title: String
    public let detail: String?
    public let checkpoint: String?
    /// Prazo do servidor para uma espera externa; o cliente não calcula nem
    /// inventa uma contagem regressiva quando o contrato não o fornece.
    public let deadline: String?
    /// Instante canônico em que uma atenção/espera começou. É opcional somente
    /// para traces legados; estados novos pausáveis o publicam para congelar o
    /// timer no mesmo ponto em todas as superfícies.
    public let pausedAt: String?
    /// `nil` somente para traces legados. Quando existe, é o único relógio
    /// autorizado para Lock Screen, Dynamic Island e handoff entre devices.
    public let timer: Timer?
    public let actions: [Action]

    public init?(metadata: JSONObject?) {
        guard let value = metadata?["presentation_state"],
              case .object(let object) = value,
              object["schema"]?.stringValue == "atlas.execution.presentation.v1",
              let kindValue = object["kind"]?.stringValue,
              let kind = Kind(rawValue: kindValue),
              let title = Self.text(object["title"], limit: 160)
        else { return nil }

        let actions: [Action]
        if let rawActions = object["actions"] {
            guard case .array(let values) = rawActions else { return nil }
            actions = values.compactMap(Self.action)
            guard actions.count == values.count else { return nil }
        } else {
            actions = []
        }

        let pausedAt: String?
        if object["paused_at"] != nil {
            guard let value = Self.timestamp(object["paused_at"]) else { return nil }
            pausedAt = value
        } else {
            pausedAt = nil
        }

        let timer: Timer?
        if let rawTimer = object["timer"] {
            guard let decodedTimer = Self.timer(rawTimer) else { return nil }
            timer = decodedTimer
        } else {
            timer = nil
        }

        // Um estado e seu relógio pertencem ao mesmo recibo público. Aceitar
        // "aguardando decisão" com tempo correndo (ou "concluído" sem relógio
        // congelado) faria app, Lock Screen e Dynamic Island discordarem. Os
        // traces legados continuam válidos sem timer; contratos novos falham
        // fechados quando os dois campos se contradizem.
        guard timer.map({ Self.isTimerCompatible($0, with: kind) }) ?? true else { return nil }

        self.kind = kind
        self.title = title
        self.detail = Self.text(object["detail"], limit: 480)
        self.checkpoint = Self.text(object["checkpoint"], limit: 120)
        self.deadline = Self.text(object["deadline"], limit: 80)
        self.pausedAt = pausedAt
        self.timer = timer
        self.actions = actions
    }
}
