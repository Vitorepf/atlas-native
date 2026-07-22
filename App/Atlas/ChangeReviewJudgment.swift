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


    // MARK: - Chrome spoken
    // MARK: Run actions (WAVE post · run CTA chrome)

    static let spokenApplying = "registrando decisão"
    static let spokenAccept = "aceitar todos os arquivos e concluir revisão"
    static let spokenAcceptHint = "aceita cada arquivo capturado e depois conclui o run"
    static let spokenReject = "rejeitar revisão inteira"
    static let spokenRejectHint = "rejeita o run de engenharia desta execução"
    static let spokenDiffUnavailable = "diff indisponível para este patch"

    static func spokenAcceptPatch(_ displayName: String) -> String {
        "aceitar \(displayName)"
    }

    static func spokenRejectPatch(_ displayName: String) -> String {
        "rejeitar \(displayName)"
    }

    // MARK: Patch card spoken (IDLE peel from PatchBody A11y)

    static func spokenPatchCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        var parts = ["patch \(String(patch.id.prefix(8)))"]
        if let files = spokenPatchFileCounts(
            changed: patch.changedFiles.count,
            created: patch.createdFiles.count,
            deleted: patch.deletedFiles.count
        ) {
            parts.append(files)
        }
        if let risk = spokenPatchRiskFlagsOptional(patch.riskFlags) {
            parts.append(risk)
        }
        parts.append(diffExpanded ? "diff expandido" : "diff recolhido")
        return parts.joined(separator: ", ")
    }

    static func spokenDiffToggle(expanded: Bool) -> String {
        expanded ? "fechar diff do patch" : "ver diff do patch"
    }

    static func spokenRiskFlagsLabel(_ flags: [String]) -> String {
        "alertas de risco, \(flags.joined(separator: ", "))"
    }

    static func spokenPatchFileCounts(changed: Int, created: Int, deleted: Int) -> String? {
        let total = changed + created + deleted
        guard total > 0 else { return nil }
        var fileParts: [String] = []
        if changed > 0 { fileParts.append("\(changed) alterado\(changed == 1 ? "" : "s")") }
        if created > 0 { fileParts.append("\(created) novo\(created == 1 ? "" : "s")") }
        if deleted > 0 { fileParts.append("\(deleted) removido\(deleted == 1 ? "" : "s")") }
        return fileParts.joined(separator: ", ")
    }

    static func spokenPatchRiskFlagsOptional(_ flags: [String]) -> String? {
        guard !flags.isEmpty else { return nil }
        return "alertas \(flags.joined(separator: ", "))"
    }

    static func spokenFindingsSection(count: Int) -> String {
        "achados, \(count) no total"
    }

    // MARK: Governance chrome (WAVE-099)

    static let spokenHashWarning =
        "atenção: o hash do diff não confere com o artefato registrado"
    static let spokenCouncilDivergence = "divergência entre pareceres"

    static func spokenCouncilSection(memberCount: Int, diverged: Bool) -> String {
        var parts = [
            "conselho, \(memberCount) \(memberCount == 1 ? "membro" : "membros")"
        ]
        if diverged { parts.append(spokenCouncilDivergence) }
        return parts.joined(separator: ", ")
    }

    static func spokenDiffStats(_ stats: AtlasTraceGovernance.DiffStats) -> String {
        "\(stats.filesTouched) arquivos, mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas"
    }

    static func packGovernanceFacts(
        stats: AtlasTraceGovernance.DiffStats?,
        revisionCount: Int,
        councilCount: Int,
        diverged: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        if let stats {
            facts.append("gov_files: \(stats.filesTouched)")
            facts.append("gov_lines_added: \(stats.linesAdded)")
            facts.append("gov_lines_removed: \(stats.linesRemoved)")
        } else {
            absences.append("diff stats de governança não publicados")
        }
        facts.append("gov_plan_revisions: \(revisionCount)")
        facts.append("gov_council_members: \(councilCount)")
        if diverged {
            facts.append("gov_council_diverged: true")
        }
        if councilCount == 0 {
            absences.append("sem conselho publicado neste recorte")
        }
        return (facts, absences)
    }

    // MARK: Section spoken (IDLE · was ChangeReviewSectionsA11y)

    static func spokenCaption(_ text: String) -> String {
        text.lowercased()
    }

    static func spokenControl(_ control: AtlasTraceChangeReview.Control) -> String {
        "\(control.slug), status \(control.status), \(control.signalSummary)"
    }

    static func spokenControlsSection(_ controls: [AtlasTraceChangeReview.Control]) -> String {
        let passed = controls.filter { $0.status == "pass" || $0.status == "passed" }.count
        var parts = ["controles, \(controls.count) no total"]
        if passed > 0 { parts.append("\(passed) aprovado\(passed == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }

    static func spokenTest(_ test: AtlasTraceChangeReview.TestRun) -> String {
        "\(test.command ?? "teste"), status \(test.status)"
    }

    static func spokenTestsSection(_ tests: [AtlasTraceChangeReview.TestRun]) -> String {
        let passed = tests.filter { $0.status == "passed" }.count
        var parts = ["testes, \(tests.count) no total"]
        if passed > 0 { parts.append("\(passed) passou\(passed == 1 ? "" : "ram")") }
        return parts.joined(separator: ", ")
    }

    static func spokenDecidedAction(_ action: AtlasTraceChangeReview.OperatorAction) -> String {
        var parts = [action.action == .accept ? "aceito" : "rejeitado"]
        if let at = action.actedAt?.nonEmpty { parts.append(at) }
        return parts.joined(separator: ", ")
    }

    static func spokenDecidedSection(_ actions: [AtlasTraceChangeReview.OperatorAction]) -> String {
        let accepted = actions.filter { $0.action == .accept }.count
        var parts = ["decisões registradas, \(actions.count) no total"]
        if accepted > 0 { parts.append("\(accepted) aceita\(accepted == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }

    static func spokenRunHeader(run: AtlasTraceChangeReview.Run) -> String {
        var parts = [run.decision ?? run.status ?? "revisão"]
        if let finished = run.finishedAt?.nonEmpty { parts.append("concluída \(finished)") }
        if let score = run.score { parts.append("pontuação \(score)") }
        return parts.joined(separator: ", ")
    }

    static func spokenToast(_ text: String) -> String {
        "aviso, \(text)"
    }

}

// MARK: - ChangeReviewSheetJudgment

// MARK: - Types

/// Exclusive change-review sheet load face (WAVE-063).
enum ChangeReviewSheetFace: Equatable {
    case loading
    case unavailable
    case empty
    case ready

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "consultando"
        case .unavailable:
            return "indisponível"
        case .empty:
            return "ligada, sem patches nem provas publicadas"
        case .ready:
            return "disponível"
        }
    }
}

// MARK: - Judgment

/// Pure change-review sheet load grammar — face · spoken · pack.
enum ChangeReviewSheetJudgment {

    static let spokenSheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"
    static let spokenClose = "fechar revisão de mudanças"
    static let spokenCloseHint = "volta para a conversa"
    static let spokenDiffToggleHint = "mostra ou oculta o conteúdo do diff para este patch"
    static let spokenAcceptFileHint = "registra aceite deste arquivo no patch"
    static let spokenRejectFileHint = "registra rejeição deste arquivo no patch"

    static func face(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> ChangeReviewSheetFace {
        guard let review else {
            return loadFinished ? .unavailable : .loading
        }
        switch review.state {
        case .unavailable:
            return .unavailable
        case .available:
            if ChangeReviewJudgment.hasReviewSurface(review) {
                return .ready
            }
            return .empty
        }
    }

    /// Full sheet accessibility label (load + available supplements).
    static func spokenSheet(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> String {
        let face = face(loadFinished: loadFinished, review: review)
        switch face {
        case .loading:
            return "revisão de mudanças, consultando"
        case .unavailable:
            if review == nil {
                return "revisão de mudanças, indisponível"
            }
            return "revisão de mudanças indisponível"
        case .empty:
            return "revisão de mudanças ligada, sem patches nem provas publicadas"
        case .ready:
            return spokenReady(review!)
        }
    }

    static func spokenReady(_ review: AtlasTraceChangeReview) -> String {
        let patches = review.patches.count
        var parts = [
            "revisão de mudanças disponível",
            "\(patches) patch\(patches == 1 ? "" : "es")"
        ]
        if let risk = ChangeReviewJudgment.spokenSheetSupplement(from: review) {
            parts.append(risk)
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(loadFinished: loadFinished, review: review)
        facts.append("review_sheet_face: \(face.productWord)")
        switch face {
        case .loading:
            absences.append("revisão ainda consultando")
        case .unavailable:
            absences.append("revisão indisponível neste recorte")
            if let reason = review?.reason, !reason.isEmpty {
                facts.append("review_reason: \(reason)")
            }
        case .empty:
            absences.append("revisão sem patches/checks/achados publicados")
        case .ready:
            if let review {
                facts.append("review_patches: \(review.patches.count)")
                facts.append("review_findings: \(review.review.findings.count)")
            }
        }
        return (facts, absences)
    }
}

// MARK: - ChangeReviewControlJudgment

// MARK: - Types

/// Exclusive change-review control face (WAVE-175) — assinatura run + file.
enum ChangeReviewControlFace: Equatable {
    /// Review missing / no control surface.
    case empty
    /// Surface exists but no accept/reject published.
    case silent
    /// Run-level availableActions non-empty.
    case runActions(accept: Bool, reject: Bool)
    /// No run actions; files still undecided (file CTAs only).
    case fileUndecided(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .silent: return "silent"
        case .runActions: return "run_actions"
        case .fileUndecided: return "file_undecided"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "revisão sem controle publicado"
        case .silent:
            return "revisão sem ações aceitar ou rejeitar publicadas"
        case .runActions(let accept, let reject):
            var parts: [String] = ["ações de assinatura publicadas"]
            if accept { parts.append("aceitar") }
            if reject { parts.append("rejeitar") }
            return parts.joined(separator: ", ")
        case .fileUndecided(let n):
            return n == 1
                ? "1 arquivo ainda sem decisão no patch"
                : "\(n) arquivos ainda sem decisão no patch"
        }
    }
}

// MARK: - Judgment

/// Pure change-review control grammar — face · pack · CTA labels.
/// Never invents availableActions. NL never applies review (face CTA only).
enum ChangeReviewControlJudgment {

    // MARK: Labels (one law file + run)

    static let productAcceptRun = "Aceitar tudo"
    static let productRejectRun = "Rejeitar"
    static let productAcceptFile = "aceitar"
    static let productRejectFile = "rejeitar"
    static let nlNeverAppliesAbsence =
        "NL de chat não aplica revisão — só CTAs do sheet (faceCTALocal)"

    // MARK: Counts

    /// Files listed on patches without a matching fileReview decision.
    static func undecidedFileCount(from review: AtlasTraceChangeReview) -> Int {
        var count = 0
        for patch in review.patches {
            let decided = Set(patch.fileReviews.map(\.filePath))
            var paths = Set(patch.changedFiles)
            paths.formUnion(patch.createdFiles)
            paths.formUnion(patch.deletedFiles)
            for path in paths where !decided.contains(path) {
                count += 1
            }
        }
        return count
    }

    static func decidedFileCount(from review: AtlasTraceChangeReview) -> Int {
        review.patches.reduce(0) { $0 + $1.fileReviews.count }
    }

    static func hasPublishedControlActions(from review: AtlasTraceChangeReview?) -> Bool {
        guard let review else { return false }
        if !review.review.availableActions.isEmpty { return true }
        return undecidedFileCount(from: review) > 0
    }

    // MARK: Face

    static func face(from review: AtlasTraceChangeReview?) -> ChangeReviewControlFace {
        guard let review else { return .empty }
        let actions = review.review.availableActions
        if !actions.isEmpty {
            return .runActions(
                accept: actions.contains(.accept),
                reject: actions.contains(.reject)
            )
        }
        let undecided = undecidedFileCount(from: review)
        if undecided > 0 { return .fileUndecided(undecided) }
        if ChangeReviewJudgment.hasReviewSurface(review) {
            return .silent
        }
        return .empty
    }

    // MARK: Pack

    static func packFacts(
        from review: AtlasTraceChangeReview?,
        applying: Bool? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: review)
        facts.append("review_control_face: \(face.productWord)")

        guard let review else {
            absences.append("revisão de mudanças não hidratada — sem availableActions")
            absences.append(nlNeverAppliesAbsence)
            return (facts, absences)
        }

        let actions = review.review.availableActions
        if actions.isEmpty {
            absences.append("sem ações de assinatura publicadas (availableActions vazio)")
        } else {
            facts.append("review_available_actions: \(actions.map(\.rawValue).joined(separator: "|"))")
            for action in actions {
                facts.append("review_action: \(action.rawValue)")
            }
            if actions.contains(.accept) {
                facts.append("review_cta_run_accept: \(productAcceptRun)")
            }
            if actions.contains(.reject) {
                facts.append("review_cta_run_reject: \(productRejectRun)")
            }
        }

        let undecided = undecidedFileCount(from: review)
        let decided = decidedFileCount(from: review)
        if undecided > 0 {
            facts.append("review_files_undecided: \(undecided)")
            facts.append("review_cta_file_accept: \(productAcceptFile)")
            facts.append("review_cta_file_reject: \(productRejectFile)")
        } else if !review.patches.isEmpty {
            absences.append("nenhum arquivo pendente de decisão no patch")
        }
        if decided > 0 {
            facts.append("review_files_decided: \(decided)")
        }

        if !review.review.operatorActions.isEmpty {
            facts.append("review_operator_actions: \(review.review.operatorActions.count)")
        }

        if let applying {
            facts.append("review_applying: \(applying ? "yes" : "no")")
        } else {
            absences.append("applying é estado local do sheet — pack não inventa")
        }

        absences.append(nlNeverAppliesAbsence)
        return (facts, absences)
    }
}
