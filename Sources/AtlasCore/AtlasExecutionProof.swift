import Foundation

public struct AtlasDecisionSummary: Sendable, Equatable {
    public let selectedProvider: String?
    public let selectedModel: String?
    public let reason: String?
    public let confidenceScore: Double?
    public let riskLevel: String?
    public let routeMode: String?
    public let wasOverridden: Bool
}

public struct AtlasQualitySummary: Sendable, Equatable {
    public let score: Double
    public let status: String
    public let evaluatorVersion: String
    public let flagCount: Int
    public let actionCount: Int
}

public extension AtlasAiTrace {
    var decisionSummary: AtlasDecisionSummary? {
        guard decisionReceipt != nil || atlasDecision != nil || routerDecision != nil else { return nil }
        return AtlasDecisionSummary(
            selectedProvider: decisionReceipt?.selectedProvider
                ?? atlasDecision?.selectedProvider
                ?? routerDecision?.selectedProvider,
            selectedModel: decisionReceipt?.selectedModel ?? atlasDecision?.selectedModel,
            reason: decisionReceipt?.reason ?? atlasDecision?.reason ?? routerDecision?.reason,
            confidenceScore: atlasDecision?.confidenceScore,
            riskLevel: atlasDecision?.riskLevel,
            routeMode: atlasDecision?.routeMode ?? routerDecision?.mode,
            wasOverridden: decisionReceipt?.wasOverridden
                ?? atlasDecision?.wasOverridden
                ?? routerDecision?.wasOverridden
                ?? false
        )
    }

    var qualitySummary: AtlasQualitySummary? {
        guard let qualityEvaluation else { return nil }
        return AtlasQualitySummary(
            score: qualityEvaluation.score,
            status: qualityEvaluation.status,
            evaluatorVersion: qualityEvaluation.evaluatorVersion,
            flagCount: qualityEvaluation.flags?.count ?? 0,
            actionCount: max(qualityEvaluation.actions?.count ?? 0, qualityActions?.count ?? 0)
        )
    }

    var toolActivities: [AtlasAgentActivity] {
        (toolEvents ?? []).enumerated().map { index, event in
            let lower = event.kind?.lowercased() ?? event.tool.lowercased()
            let kind: AtlasAgentActivity.Kind
            let title: String
            if event.error != nil || (event.exitCode.map { $0 != 0 } ?? false) {
                kind = .warning; title = "Ferramenta terminou com falha"
            } else if lower.contains("edit") || lower.contains("write") || lower.contains("patch") || lower.contains("apply") {
                kind = .editing; title = "Editando arquivos"
            } else if lower.contains("read") || lower.contains("open") || lower.contains("search") || lower.contains("find") {
                kind = .reading; title = "Lendo o projeto"
            } else if lower.contains("test") || lower.contains("check") || lower.contains("verify") {
                kind = .verifying; title = "Verificando o resultado"
            } else {
                kind = .executing; title = "Usando \(event.tool)"
            }
            return AtlasAgentActivity(
                id: event.id,
                sequence: index,
                kind: kind,
                title: title,
                detail: firstChangedFile(event.changedFiles),
                occurredAt: event.occurredAt ?? event.createdAt
            )
        }
    }
}

private func firstChangedFile(_ values: [JSONValue]?) -> String? {
    guard let first = values?.first else { return nil }
    let path: String?
    switch first {
    case .string(let value): path = value
    case .object(let object):
        path = object["path"]?.stringValue ?? object["file"]?.stringValue
    default: path = nil
    }
    return path.map { ($0 as NSString).lastPathComponent }
}
