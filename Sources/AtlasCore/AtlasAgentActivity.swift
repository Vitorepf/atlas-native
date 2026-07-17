import Foundation

/// Um passo observável da execução do agente. É uma projeção segura do wire:
/// mostra trabalho real sem despejar stdout, prompts, ids internos ou cadeia de
/// raciocínio. A View decide apresentação; o Core decide semântica e redaction.
public struct AtlasAgentActivity: Sendable, Equatable, Identifiable {
    public enum Kind: String, Sendable, Equatable {
        case understanding
        case context
        case planning
        case permission
        case reasoning
        case executing
        case reading
        case editing
        case verifying
        case evidence
        case completed
        case warning
        case progress
    }

    public let id: String
    public let sequence: Int
    public let kind: Kind
    public let title: String
    public let detail: String?
    public let occurredAt: String?

    public init(
        id: String,
        sequence: Int,
        kind: Kind,
        title: String,
        detail: String? = nil,
        occurredAt: String? = nil
    ) {
        self.id = id
        self.sequence = sequence
        self.kind = kind
        self.title = title
        self.detail = detail
        self.occurredAt = occurredAt
    }
}
