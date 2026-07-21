import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive artifacts evidence face (WAVE-041).
enum ArtifactEvidenceFace: Equatable {
    case absent
    case unavailable(reason: String?)
    case empty
    case ready(total: Int, images: Int, diffs: Int)
    /// Ready items plus at least one failing delivery check.
    case deliveryPressure(total: Int, failing: Int)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .unavailable: return "unavailable"
        case .empty: return "empty"
        case .ready: return "ready"
        case .deliveryPressure: return "delivery_pressure"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Artefatos"
        case .unavailable: return "Artefatos indisponíveis"
        case .empty: return "Sem artefatos"
        case .ready: return "Evidência pronta"
        case .deliveryPressure: return "Entrega com falha"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "artefatos não hidratados"
        case .unavailable:
            return "artefatos da execução indisponíveis"
        case .empty:
            return "artefatos da execução, sem itens publicados"
        case .ready(let total, let images, let diffs):
            var parts = [
                total == 1 ? "1 artefato publicado" : "\(total) artefatos publicados"
            ]
            if images > 0 {
                parts.append(images == 1 ? "1 imagem" : "\(images) imagens")
            }
            if diffs > 0 {
                parts.append(diffs == 1 ? "1 diff" : "\(diffs) diffs")
            }
            return parts.joined(separator: ", ")
        case .deliveryPressure(let total, let failing):
            return "\(total) artefatos, \(failing == 1 ? "1 prova de entrega falhou" : "\(failing) provas de entrega falharam")"
        }
    }
}

// MARK: - Judgment

/// Pure artifacts evidence grammar — kind rank · face · pack · spoken.
enum ArtifactJudgment {

    // MARK: Kind rank (lower = higher attention)

    /// image 0 · diff 1 · markdown 2 · text 3 · file 4
    static func kindRank(_ kind: AtlasTraceArtifacts.Item.Kind) -> Int {
        switch kind {
        case .image: return 0
        case .diff: return 1
        case .markdown: return 2
        case .text: return 3
        case .file: return 4
        }
    }

    static func rankItems(
        _ items: [AtlasTraceArtifacts.Item]
    ) -> [AtlasTraceArtifacts.Item] {
        items.enumerated().sorted { lhs, rhs in
            let lk = kindRank(lhs.element.kind)
            let rk = kindRank(rhs.element.kind)
            if lk != rk { return lk < rk }
            // Larger visual payloads first within same kind (operator scan).
            if lhs.element.byteSize != rhs.element.byteSize {
                return lhs.element.byteSize > rhs.element.byteSize
            }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func rankDeliveryChecks(
        _ checks: [ArtifactDeliveryCheck]
    ) -> [ArtifactDeliveryCheck] {
        checks.enumerated().sorted { lhs, rhs in
            let lf = statusFailRank(lhs.element.status)
            let rf = statusFailRank(rhs.element.status)
            if lf != rf { return lf < rf }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// 0 fail · 1 running · 2 pass · 3 other (aligned with ChangeReview)
    static func statusFailRank(_ status: String) -> Int {
        switch status.lowercased() {
        case "fail", "failed", "error", "broken", "timeout": return 0
        case "running", "pending", "queued", "in_progress": return 1
        case "pass", "passed", "ok", "success", "succeeded": return 2
        default: return 3
        }
    }

    static func failingDeliveryCount(_ checks: [ArtifactDeliveryCheck]) -> Int {
        checks.filter { statusFailRank($0.status) == 0 }.count
    }

    // MARK: Face

    static func face(
        artifacts: AtlasTraceArtifacts?,
        deliveryChecks: [ArtifactDeliveryCheck] = []
    ) -> ArtifactEvidenceFace {
        guard let artifacts else { return .absent }
        switch artifacts.state {
        case .unavailable:
            return .unavailable(reason: artifacts.reason)
        case .available:
            let items = artifacts.items
            if items.isEmpty { return .empty }
            let images = items.filter { $0.kind == .image }.count
            let diffs = items.filter { $0.kind == .diff }.count
            let failing = failingDeliveryCount(deliveryChecks)
            if failing > 0 {
                return .deliveryPressure(total: items.count, failing: failing)
            }
            return .ready(total: items.count, images: images, diffs: diffs)
        }
    }

    static func summaryLine(
        artifacts: AtlasTraceArtifacts?,
        deliveryChecks: [ArtifactDeliveryCheck] = []
    ) -> String {
        switch face(artifacts: artifacts, deliveryChecks: deliveryChecks) {
        case .absent:
            return "não hidratado"
        case .unavailable:
            return "indisponível"
        case .empty:
            return "sem itens publicados"
        case .ready(let total, let images, let diffs):
            var parts = ["\(total) itens"]
            if images > 0 { parts.append("img \(images)") }
            if diffs > 0 { parts.append("diff \(diffs)") }
            return parts.joined(separator: " · ")
        case .deliveryPressure(let total, let failing):
            return "\(total) itens · falhas entrega \(failing)"
        }
    }

    // MARK: Spoken / pack

    static func spokenSheet(
        artifacts: AtlasTraceArtifacts?,
        deliveryChecks: [ArtifactDeliveryCheck] = []
    ) -> String {
        let face = face(artifacts: artifacts, deliveryChecks: deliveryChecks)
        switch face {
        case .absent:
            return "artefatos da execução"
        case .unavailable, .empty, .ready, .deliveryPressure:
            return "artefatos da execução, \(face.spokenFace)"
        }
    }

    static func packFacts(
        artifacts: AtlasTraceArtifacts?,
        deliveryChecks: [ArtifactDeliveryCheck] = []
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(artifacts: artifacts, deliveryChecks: deliveryChecks)
        facts.append("artifact_face: \(face.productWord)")
        guard let artifacts else {
            absences.append("artefatos não hidratados neste recorte")
            return (facts, absences)
        }
        if artifacts.state == .unavailable {
            absences.append("artefatos indisponíveis no contrato")
            if let reason = artifacts.reason, !reason.isEmpty {
                facts.append("reason: \(reason)")
            }
            return (facts, absences)
        }
        facts.append(summaryLine(artifacts: artifacts, deliveryChecks: deliveryChecks))
        for item in rankItems(artifacts.items).prefix(6) {
            facts.append(
                "item: \(item.kind.rawValue) · \(item.name) · \(item.byteSize)B"
            )
        }
        if artifacts.items.isEmpty {
            absences.append("lista de artefatos vazia no estado available")
        }
        let failing = failingDeliveryCount(deliveryChecks)
        if failing > 0 {
            facts.append("delivery_failures: \(failing)")
        }
        return (facts, absences)
    }
}
