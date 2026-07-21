import Foundation
import AtlasCore
import SwiftUI

// MARK: - Types

/// Exclusive risk face for change review (WAVE-039).
enum ChangeReviewRiskFace: Equatable {
    /// Review payload missing or no surface rows.
    case empty
    /// Surface exists; no critical/high findings and no risk-flagged patches.
    case quiet
    /// High/medium risk or risk-flagged patches without critical.
    case elevated(high: Int, medium: Int, riskPatches: Int)
    /// At least one critical finding.
    case critical(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .quiet: return "quiet"
        case .elevated: return "elevated"
        case .critical: return "critical"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Revisão"
        case .quiet: return "Risco quieto"
        case .elevated: return "Risco elevado"
        case .critical: return "Risco crítico"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "revisão sem superfície de risco"
        case .quiet:
            return "risco quieto, sem achados críticos nem patches com bandeiras"
        case .elevated(let high, let medium, let riskPatches):
            var parts: [String] = ["risco elevado"]
            if high > 0 { parts.append(high == 1 ? "1 alta" : "\(high) altas") }
            if medium > 0 { parts.append(medium == 1 ? "1 média" : "\(medium) médias") }
            if riskPatches > 0 {
                parts.append(riskPatches == 1 ? "1 patch com bandeira" : "\(riskPatches) patches com bandeira")
            }
            return parts.joined(separator: ", ")
        case .critical(let n):
            return n == 1
                ? "risco crítico, 1 achado crítico"
                : "risco crítico, \(n) achados críticos"
        }
    }
}

// MARK: - Judgment

/// Pure risk grammar for Revisar mudanças — rank · face · pack · spoken.
enum ChangeReviewJudgment {

    // MARK: Severity rank (lower = higher attention)

    /// 0 critical · 1 high · 2 medium · 3 low · 4 nil/unknown
    static func severityRank(_ severity: String?) -> Int {
        switch (severity ?? "").lowercased() {
        case "critical", "crit": return 0
        case "high", "error": return 1
        case "medium", "med", "warn", "warning": return 2
        case "low", "info": return 3
        default: return 4
        }
    }

    static func severitySpoken(_ severity: String?) -> String {
        switch (severity ?? "").lowercased() {
        case "critical", "crit": return "crítica"
        case "high", "error": return "alta"
        case "medium", "med", "warn", "warning": return "média"
        case "low", "info": return "baixa"
        case "": return "sem severidade"
        default: return severity ?? "sem severidade"
        }
    }

    static func severityColor(_ severity: String?) -> Color {
        switch severityRank(severity) {
        case 0, 1: return AtlasTheme.domOperacional
        case 2: return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }

    // MARK: Findings

    static func rankFindings(_ findings: [AtlasTraceChangeReview.Finding]) -> [AtlasTraceChangeReview.Finding] {
        findings.enumerated().sorted { lhs, rhs in
            let lr = severityRank(lhs.element.severity)
            let rr = severityRank(rhs.element.severity)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// Axis groups ordered by worst severity in the group; findings severity-first inside.
    static func rankedAxisGroups(
        _ findings: [AtlasTraceChangeReview.Finding]
    ) -> [(axis: String, findings: [AtlasTraceChangeReview.Finding])] {
        let ranked = rankFindings(findings)
        let grouped = Dictionary(grouping: ranked) { $0.category?.uppercased() ?? "GERAIS" }
        return grouped.keys.sorted { a, b in
            let aw = worstSeverityRank(grouped[a] ?? [])
            let bw = worstSeverityRank(grouped[b] ?? [])
            if aw != bw { return aw < bw }
            return a < b
        }.map { axis in
            (axis: axis, findings: grouped[axis] ?? [])
        }
    }

    static func worstSeverityRank(_ findings: [AtlasTraceChangeReview.Finding]) -> Int {
        findings.map { severityRank($0.severity) }.min() ?? 4
    }

    static func count(severityRank target: Int, in findings: [AtlasTraceChangeReview.Finding]) -> Int {
        findings.filter { severityRank($0.severity) == target }.count
    }

    // MARK: Patches

    /// Risk flags first (desc), then total file footprint, wire-stable.
    static func rankPatches(_ patches: [AtlasTraceChangeReview.Patch]) -> [AtlasTraceChangeReview.Patch] {
        patches.enumerated().sorted { lhs, rhs in
            let lf = lhs.element.riskFlags.count
            let rf = rhs.element.riskFlags.count
            if lf != rf { return lf > rf }
            let lFiles = fileFootprint(lhs.element)
            let rFiles = fileFootprint(rhs.element)
            if lFiles != rFiles { return lFiles > rFiles }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func fileFootprint(_ patch: AtlasTraceChangeReview.Patch) -> Int {
        patch.changedFiles.count + patch.createdFiles.count + patch.deletedFiles.count
    }

    static func riskPatchCount(_ patches: [AtlasTraceChangeReview.Patch]) -> Int {
        patches.filter { !$0.riskFlags.isEmpty }.count
    }

    // MARK: Controls / tests (fail-first)

    static func rankControls(_ controls: [AtlasTraceChangeReview.Control]) -> [AtlasTraceChangeReview.Control] {
        controls.enumerated().sorted { lhs, rhs in
            let lf = statusFailRank(lhs.element.status)
            let rf = statusFailRank(rhs.element.status)
            if lf != rf { return lf < rf }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func rankTests(_ tests: [AtlasTraceChangeReview.TestRun]) -> [AtlasTraceChangeReview.TestRun] {
        tests.enumerated().sorted { lhs, rhs in
            let lf = statusFailRank(lhs.element.status)
            let rf = statusFailRank(rhs.element.status)
            if lf != rf { return lf < rf }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    /// 0 fail/error · 1 running/pending · 2 pass/ok · 3 other
    static func statusFailRank(_ status: String) -> Int {
        switch status.lowercased() {
        case "fail", "failed", "error", "broken", "timeout": return 0
        case "running", "pending", "queued", "in_progress": return 1
        case "pass", "passed", "ok", "success", "succeeded": return 2
        default: return 3
        }
    }

    // MARK: Face

    static func face(from review: AtlasTraceChangeReview?) -> ChangeReviewRiskFace {
        guard let review, hasReviewSurface(review) else { return .empty }
        let findings = review.review.findings
        let critical = count(severityRank: 0, in: findings)
        if critical > 0 { return .critical(critical) }
        let high = count(severityRank: 1, in: findings)
        let medium = count(severityRank: 2, in: findings)
        let riskPatches = riskPatchCount(review.patches)
        if high > 0 || medium > 0 || riskPatches > 0 {
            return .elevated(high: high, medium: medium, riskPatches: riskPatches)
        }
        return .quiet
    }

    /// Same honesty gate as the sheet — never invent surface.
    static func hasReviewSurface(_ review: AtlasTraceChangeReview) -> Bool {
        !review.patches.isEmpty
            || !review.controls.isEmpty
            || !review.testRuns.isEmpty
            || !review.review.findings.isEmpty
            || !review.review.operatorActions.isEmpty
            || !review.review.availableActions.isEmpty
    }

    static func summaryLine(from review: AtlasTraceChangeReview) -> String {
        let findings = review.review.findings
        let critical = count(severityRank: 0, in: findings)
        let high = count(severityRank: 1, in: findings)
        let medium = count(severityRank: 2, in: findings)
        let riskPatches = riskPatchCount(review.patches)
        var parts: [String] = []
        if critical > 0 { parts.append("críticos \(critical)") }
        if high > 0 { parts.append("altas \(high)") }
        if medium > 0 { parts.append("médias \(medium)") }
        if findings.count > 0 { parts.append("achados \(findings.count)") }
        if !review.patches.isEmpty {
            parts.append("patches \(review.patches.count)")
        }
        if riskPatches > 0 { parts.append("bandeiras \(riskPatches)") }
        if parts.isEmpty { return "sem sinais de risco publicados" }
        return parts.joined(separator: " · ")
    }

    // MARK: Pack / spoken

    static func packFacts(from review: AtlasTraceChangeReview?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: review)
        facts.append("review_risk_face: \(face.productWord)")
        guard let review else {
            absences.append("revisão de mudanças não hidratada neste recorte")
            return (facts, absences)
        }
        if !hasReviewSurface(review) {
            absences.append("revisão ligada sem patches, checks, testes ou achados")
            return (facts, absences)
        }
        facts.append(summaryLine(from: review))
        for f in rankFindings(review.review.findings).prefix(5) {
            let sev = f.severity ?? "nil"
            let title = f.title ?? f.id
            facts.append("finding: \(sev) · \(title)")
        }
        for p in rankPatches(review.patches).prefix(3) {
            let flags = p.riskFlags.isEmpty ? "sem bandeira" : p.riskFlags.joined(separator: ",")
            facts.append("patch: \(String(p.id.prefix(8))) · \(flags)")
        }
        if review.review.findings.isEmpty {
            absences.append("nenhum achado publicado")
        }
        if review.patches.isEmpty {
            absences.append("nenhum patch publicado")
        }
        return (facts, absences)
    }

    static func spokenSheetSupplement(from review: AtlasTraceChangeReview?) -> String? {
        let face = face(from: review)
        switch face {
        case .empty, .quiet:
            return face.spokenFace
        case .elevated, .critical:
            return face.spokenFace
        }
    }

    // MARK: Run actions (WAVE post · run CTA chrome)

    static let applyingLabel = "registrando decisão"
    static let acceptLabel = "aceitar todos os arquivos e concluir revisão"
    static let acceptHint = "aceita cada arquivo capturado e depois conclui o run"
    static let rejectLabel = "rejeitar revisão inteira"
    static let rejectHint = "rejeita o run de engenharia desta execução"
    static let diffUnavailableLabel = "diff indisponível para este patch"

    static func spokenAcceptPatch(_ displayName: String) -> String {
        "aceitar \(displayName)"
    }

    static func spokenRejectPatch(_ displayName: String) -> String {
        "rejeitar \(displayName)"
    }
}

