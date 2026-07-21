import Foundation
import AtlasCore

// MARK: - Digest / moment judgment (WAVE-038)

enum AutonomosDigestFace: Equatable {
    case absent
    case quiet
    case attention(pending: Int, risks: Int)
    case delivered(Int)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .quiet: return "quiet"
        case .attention: return "attention"
        case .delivered: return "delivered"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent: return "digest não publicado"
        case .quiet: return "digest quieto nesta janela"
        case .attention(let p, let r):
            return "digest com \(p) decisões e \(r) riscos"
        case .delivered(let n):
            return n == 1 ? "1 entrega no digest" : "\(n) entregas no digest"
        }
    }

    var heroTitle: String {
        switch self {
        case .absent: return "Sem digest"
        case .quiet: return "Janela quieta"
        case .attention: return "Digest pede atenção"
        case .delivered: return "Entregas no digest"
        }
    }
}

enum AutonomosDigestJudgment {

    static func face(from digest: AtlasAutonomosDigestResponse?) -> AutonomosDigestFace {
        guard let digest else { return .absent }
        let c = digest.last.counts
        if c.pendingDecisions > 0 || c.risks > 0 {
            return .attention(pending: c.pendingDecisions, risks: c.risks)
        }
        if c.delivered > 0 {
            return .delivered(c.delivered)
        }
        return .quiet
    }

    static func isPublished(_ digest: AtlasAutonomosDigestResponse?) -> Bool {
        digest != nil
    }

    static func windowLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let w = digest.last.window
        return "\(w.hours)h · \(w.kind) · \(w.focus) · \(w.timezone)"
    }

    static func countsLine(_ digest: AtlasAutonomosDigestResponse) -> String {
        let c = digest.last.counts
        return "entregas \(c.delivered) · riscos \(c.risks) · decisões \(c.pendingDecisions)"
    }

    static func scheduleLine(_ digest: AtlasAutonomosDigestResponse) -> String? {
        let s = digest.schedule
        if !s.available {
            let reason = s.reason?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return reason.isEmpty ? "agenda indisponível" : "agenda: \(reason)"
        }
        if let next = digest.nextDigestAt?.trimmingCharacters(in: .whitespacesAndNewlines), !next.isEmpty {
            return "próximo digest \(next)"
        }
        return "agenda disponível"
    }

    /// Higher priority first; stable title.
    static func rankPending(
        _ items: [AtlasAutonomosDigestPendingDecision]
    ) -> [AtlasAutonomosDigestPendingDecision] {
        items.sorted { lhs, rhs in
            if lhs.priorityScore != rhs.priorityScore {
                return lhs.priorityScore > rhs.priorityScore
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    /// Severity order: critical > high > medium > low > other.
    static func rankRisks(_ items: [AtlasAutonomosDigestRisk]) -> [AtlasAutonomosDigestRisk] {
        func sev(_ s: String) -> Int {
            switch s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "critical", "critico", "crítico": return 0
            case "high", "alto": return 1
            case "medium", "med", "médio", "medio": return 2
            case "low", "baixo": return 3
            default: return 4
            }
        }
        return items.sorted { lhs, rhs in
            let ls = sev(lhs.severity)
            let rs = sev(rhs.severity)
            if ls != rs { return ls < rs }
            let lt = lhs.title ?? ""
            let rt = rhs.title ?? ""
            return lt.localizedCaseInsensitiveCompare(rt) == .orderedAscending
        }
    }

    static func rankDelivered(
        _ items: [AtlasAutonomosDigestDelivered]
    ) -> [AtlasAutonomosDigestDelivered] {
        items.sorted { lhs, rhs in
            if lhs.mergePerformed != rhs.mergePerformed {
                return lhs.mergePerformed && !rhs.mergePerformed
            }
            return lhs.recordedAt > rhs.recordedAt
        }
    }

    static func hubMeta(from digest: AtlasAutonomosDigestResponse?) -> String? {
        guard let digest else { return nil }
        let c = digest.last.counts
        if c.pendingDecisions + c.risks + c.delivered == 0 {
            return "janela quieta"
        }
        return countsLine(digest)
    }

    static func packFacts(_ digest: AtlasAutonomosDigestResponse?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: digest)
        facts.append("digest_face: \(face.productWord)")
        guard let digest else {
            absences.append("digest não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("digest_window: \(windowLine(digest))")
        facts.append("digest_counts: \(countsLine(digest))")
        if let schedule = scheduleLine(digest) {
            facts.append("digest_schedule: \(schedule)")
        }
        for d in rankDelivered(digest.last.delivered).prefix(4) {
            facts.append("digest_entrega: ciclo \(d.cycleIndex) · \(d.outcome)")
        }
        for r in rankRisks(digest.last.risks).prefix(4) {
            facts.append("digest_risco: \(r.severity) · \(r.title ?? r.reason ?? r.id)")
        }
        for p in rankPending(digest.last.pendingDecisions).prefix(4) {
            facts.append("digest_decisao: \(p.title) · prio \(p.priorityScore)")
        }
        if digest.last.counts.delivered + digest.last.counts.risks + digest.last.counts.pendingDecisions == 0 {
            absences.append("digest sem itens nesta janela — silêncio honesto")
        }
        return (facts, absences)
    }

    // MARK: Row spoken (WAVE-104)

    static func spokenRow(title: String, meta: String) -> String {
        "\(title), \(meta)"
    }

}
