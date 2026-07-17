import Foundation

public extension AtlasAiTrace {
    /// Valor calculado do envelope que já sobrevive a stream, polling e relaunch.
    /// O DTO do trace permanece dono do wire bruto; esta extensão é o seam
    /// seguro consumido por `ConversationModel` e pelas Views.
    var executionPlan: AtlasExecutionPlan? { AtlasExecutionPlan(metadata: metadata) }

    var executionProgress: AtlasExecutionPlan.Progress? {
        executionPlan?.progress(events: streamEvents ?? [], traceStatus: status)
    }
}

// Interno ao módulo: AtlasExecutionPlan.swift também consome este helper
// (o peel o havia deixado private, quebrando a compilação cross-file).
extension JSONValue {
    var stringArray: [String]? {
        guard case .array(let values) = self else { return nil }
        let strings = values.compactMap(\.stringValue)
        return strings.count == values.count ? strings : nil
    }
}
