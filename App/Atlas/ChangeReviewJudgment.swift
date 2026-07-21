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

    static let hashWarningLabel =
        "atenção: o hash do diff não confere com o artefato registrado"
    static let councilDivergenceLabel = "divergência entre pareceres"

    static func spokenCouncilSection(memberCount: Int, diverged: Bool) -> String {
        var parts = [
            "conselho, \(memberCount) \(memberCount == 1 ? "membro" : "membros")"
        ]
        if diverged { parts.append(councilDivergenceLabel) }
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

    static let sheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"

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

    static let acceptRunLabel = "Aceitar tudo"
    static let rejectRunLabel = "Rejeitar"
    static let acceptFileLabel = "aceitar"
    static let rejectFileLabel = "rejeitar"
    static let nlNeverAppliesAbsence =
        "NL de chat não aplica revisão — só CTAs do sheet (faceCTALocal)"

    // MARK: Counts

    static func availableActions(from review: AtlasTraceChangeReview?) -> [AtlasTraceChangeReview.Action] {
        review?.review.availableActions ?? []
    }

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
                facts.append("review_cta_run_accept: \(acceptRunLabel)")
            }
            if actions.contains(.reject) {
                facts.append("review_cta_run_reject: \(rejectRunLabel)")
            }
        }

        let undecided = undecidedFileCount(from: review)
        let decided = decidedFileCount(from: review)
        if undecided > 0 {
            facts.append("review_files_undecided: \(undecided)")
            facts.append("review_cta_file_accept: \(acceptFileLabel)")
            facts.append("review_cta_file_reject: \(rejectFileLabel)")
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

    /// Spoken run CTA labels — one law with face buttons.
    static func spokenRunAccept() -> String { acceptRunLabel.lowercased() }
    static func spokenRunReject() -> String { rejectRunLabel.lowercased() }
}

// MARK: - ChangeReviewBody

// MARK: - Controls

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    private var ranked: [AtlasTraceChangeReview.Control] {
        ChangeReviewJudgment.rankControls(controls)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(ranked) { c in
                controlRow(c)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenControlsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }

    func controlRow(_ c: AtlasTraceChangeReview.Control) -> some View {
        HStack(spacing: 8) {
            Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(c.status).font(AtlasFont.mono(10))
                .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewJudgment.spokenControl(c))
    }
}

// MARK: - Decided actions

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                decidedActionRow(a)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }

    func decidedActionRow(_ a: AtlasTraceChangeReview.OperatorAction) -> some View {
        HStack(spacing: 8) {
            Text(a.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            if let at = a.actedAt {
                Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedAction(a))
    }
}

// MARK: - Tests

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    private var ranked: [AtlasTraceChangeReview.TestRun] {
        ChangeReviewJudgment.rankTests(tests)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(ranked) { t in
                testRow(t)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenTestsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }

    func testRow(_ t: AtlasTraceChangeReview.TestRun) -> some View {
        HStack(spacing: 8) {
            Text(t.command ?? "teste").font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            Spacer()
            Text(t.status).font(AtlasFont.mono(10))
                .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewJudgment.spokenTest(t))
    }
}

// MARK: - Run header

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }

    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }

    @ViewBuilder
    var runHeaderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(run.decision ?? run.status ?? "revisão")
                .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let finished = run.finishedAt {
                Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    var runHeaderScore: some View {
        if let score = run.score {
            Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Risk strip

// MARK: - Risk face strip (WAVE-039)

/// Thin chrome: exclusive risk face for Revisar mudanças.
struct ChangeReviewRiskStrip: View {
    let review: AtlasTraceChangeReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: ChangeReviewRiskFace {
        ChangeReviewJudgment.face(from: review)
    }

    var body: some View {
        switch face {
        case .empty:
            EmptyView()
        case .quiet, .elevated, .critical:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(titleColor)
                Text(ChangeReviewJudgment.summaryLine(from: review))
                    .font(AtlasFont.serif(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .fill(AtlasTheme.surface.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace + ", " + ChangeReviewJudgment.summaryLine(from: review))
        .accessibilityIdentifier(A11yID.reviewRiskFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet: return AtlasTheme.textTertiary
        case .empty: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet, .empty: return AtlasTheme.textTertiary
        }
    }

    private var borderColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional.opacity(0.35)
        case .elevated: return AtlasTheme.accent.opacity(0.28)
        case .quiet, .empty: return AtlasTheme.separatorSoft
        }
    }
}

// MARK: - ChangeReviewFindings

extension ChangeReviewFindingRow {
    var rowAccessibilityLabel: String {
        var parts: [String] = []
        if finding.severity != nil {
            parts.append("severidade \(ChangeReviewJudgment.severitySpoken(finding.severity))")
        }
        parts.append(finding.title ?? "achado sem título")
        if let path = finding.filePath {
            let line = finding.startLine.map { ", linha \($0)" } ?? ""
            parts.append("\(path)\(line)")
        }
        if let rec = finding.recommendation {
            parts.append("recomendação: \(rec)")
        }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewFindingRow {
    var findingBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(ChangeReviewJudgment.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(AtlasFont.serif(14)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            findingPathAndRecommendation
        }
        .padding(.vertical, 3)
    }
}

extension ChangeReviewFindingRow {
    @ViewBuilder
    var findingPathAndRecommendation: some View {
        if let path = finding.filePath {
            Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        if let rec = finding.recommendation {
            Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(3).padding(.top, 1)
                .accessibilityHidden(true)
        }
    }
}

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        findingBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
    }
}

extension ChangeReviewFindingsSection {
    func axisGroup(axis: String, axisFindings: [AtlasTraceChangeReview.Finding]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            axisHeaderRow(axis: axis, count: axisFindings.count)
            ForEach(axisFindings) { f in
                ChangeReviewFindingRow(finding: f)
            }
        }
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderRow(axis: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            Text("\(count)")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(axisHeaderLabel(axis: axis, count: count))
        .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}

extension ChangeReviewFindingsSection {
    /// WAVE-039: axes by worst severity; findings severity-first inside.
    var rankedGroups: [(axis: String, findings: [AtlasTraceChangeReview.Finding])] {
        ChangeReviewJudgment.rankedAxisGroups(findings)
    }
}

struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(ChangeReviewJudgment.spokenFindingsSection(count: findings.count))
            ForEach(rankedGroups, id: \.axis) { group in
                axisGroup(axis: group.axis, axisFindings: group.findings)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }
}

// MARK: - ChangeReviewPatchCard

extension ChangeReviewPatchCard {
    @ViewBuilder
    var patchCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            patchHeader
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
            }
            patchRiskFlags
            if diffExpanded {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

extension ChangeReviewPatchCard {
    var diffExpanded: Bool { expandedDiffPatch == patch.id }
}

extension ChangeReviewPatchCard {
    var patchHeader: some View {
        HStack {
            Text("PATCH \(String(patch.id.prefix(8)))")
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                .font(AtlasFont.mono(11, .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewJudgment.spokenDiffToggle(expanded: diffExpanded))
                .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
                .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
        }
    }
}

extension ChangeReviewPatchCard {
    var patchRiskFlags: some View {
        Group {
            if !patch.riskFlags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patch.riskFlags, id: \.self) { flag in
                        Text(flag).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewJudgment.spokenRiskFlagsLabel(patch.riskFlags))
            }
        }
    }
}

extension ChangeReviewPatchCard {
    func toggleDiff() {
        if diffExpanded {
            expandedDiffPatch = nil
        } else {
            expandedDiffPatch = patch.id
            Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
        }
    }
}

// MARK: - Patch / Diff (C15 · C16)
// DiffView → ChangeReviewDiffView.swift · Toggle → +Toggle · Header → +Header
// Chrome → ChangeReviewDiffSection+Chrome.swift
// Body → ChangeReviewDiffSection+Body.swift
// Expanded → ChangeReviewDiffSection+Expanded.swift
// Shell → ChangeReviewDiffSection+Shell.swift

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        patchCardShell
    }
}

// MARK: - ChangeReviewRunActions

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text("Aceitar tudo")
            .font(AtlasFont.mono(11, .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.accent))
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            applyingStaticLabel
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewJudgment.applyingLabel)
        }
    }
}

extension ChangeReviewRunActions {
    var applyingStaticLabel: some View {
        Text("registrando…")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityLabel(ChangeReviewJudgment.applyingLabel)
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func runActionButtonRow(available: [AtlasTraceChangeReview.Action]) -> some View {
        HStack(spacing: 10) {
            acceptButton(available: available)
            rejectButton(available: available)
            if applying { applyingIndicator }
        }
    }
}

extension ChangeReviewRunActions {
    func performAccept() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func acceptButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.accept) {
            Button(action: performAccept) {
                acceptButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ChangeReviewJudgment.acceptLabel)
            .accessibilityHint(ChangeReviewJudgment.acceptHint)
            .accessibilityIdentifier(A11yID.reviewRunAccept)
        }
    }
}

extension ChangeReviewRunActions {
    func rejectReviewAction() {
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                rejectReviewAction()
            } label: {
                rejectButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ChangeReviewJudgment.rejectLabel)
            .accessibilityHint(ChangeReviewJudgment.rejectHint)
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }
}

extension ChangeReviewRunActions {
    var rejectButtonLabel: some View {
        Text("Rejeitar")
            .font(AtlasFont.mono(11, .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}

struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            runActionButtonRow(available: available)
            .disabled(applying)
            .padding(.top, 4)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: applying)
        }
    }
}

// MARK: - ChangeReviewFileRowChrome

// MARK: - File row a11y
struct ChangeReviewFileRowA11y: ViewModifier {
    let decidedLabel: String?
    let identifier: String

    func body(content: Content) -> some View {
        if let decidedLabel {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(decidedLabel)
                .accessibilityIdentifier(identifier)
        } else {
            content
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(identifier)
        }
    }
}

extension ChangeReviewFileRowA11y {
    static func spoken(
        displayName: String,
        kind: String?,
        review: AtlasTraceChangeReview.FileReview
    ) -> String {
        var parts = [displayName]
        if let kind { parts.append("arquivo \(kind)") }
        parts.append(review.action == .accept ? "aceito" : "rejeitado")
        return parts.joined(separator: ", ")
    }
}

// MARK: - File row chrome
extension ChangeReviewFileRow {
    var acceptButton: some View {
        Button("aceitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .accept
                )
            }
        }
        .buttonStyle(PressableScale())
        .font(AtlasFont.mono(10, .medium)).foregroundStyle(AtlasTheme.accent)
        .accessibilityLabel(ChangeReviewJudgment.spokenAcceptPatch(displayName))
        .accessibilityHint("registra aceite deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileAccept(patchId: patch.id, filePath: file))
    }
}

extension ChangeReviewFileRow {
    var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var displayName: String { (file as NSString).lastPathComponent }

    var fileKindCaption: String? {
        if patch.createdFiles.contains(file) { return "novo" }
        if patch.deletedFiles.contains(file) { return "removido" }
        return nil
    }
}

extension ChangeReviewFileRow {
    var fileLeading: some View {
        fileLeadingRow
    }
}

extension ChangeReviewFileRow {
    var fileLeadingRow: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            }
            Spacer()
            fileTrailing
        }
    }
}

extension ChangeReviewFileRow {
    var rejectButton: some View {
        Button("rejeitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .reject
                )
            }
        }
        .buttonStyle(PressableScale())
        .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityLabel(ChangeReviewJudgment.spokenRejectPatch(displayName))
        .accessibilityHint("registra rejeição deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
    }
}

extension ChangeReviewFileRow {
    @ViewBuilder
    var fileTrailing: some View {
        if let decided {
            Text(decided.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        } else {
            acceptButton
            rejectButton
        }
    }
}

struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        fileLeading
            .padding(.vertical, 3)
            .modifier(ChangeReviewFileRowA11y(
                decidedLabel: decided.map {
                    ChangeReviewFileRowA11y.spoken(displayName: displayName, kind: fileKindCaption, review: $0)
                },
                identifier: A11yID.reviewFileRow(patchId: patch.id, filePath: file)
            ))
    }
}

// MARK: - ChangeReviewGovernance

// MARK: - Body

// WAVE-013 fused ChangeReviewView+Sections.swift

extension AtlasTraceGovernance.CouncilMember {
    var spokenCouncilLine: String {
        var parts = [provider]
        if let model = model { parts.append(model) }
        parts.append("status \(status)")
        if let hash = responseHash {
            parts.append("hash de resposta \(String(hash.prefix(12)))")
        }
        if let code = errorCode { parts.append("código \(code)") }
        if let latency = latencyMs { parts.append("\(latency) milissegundos") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerOutcomeGlyph: some View {
        Image(systemName: member.succeeded ? "checkmark" : "xmark")
            .atlasSans(9, .semibold)
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerHeader: some View {
        HStack(spacing: 7) {
            providerOutcomeGlyph
            Text(member.provider)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            providerModelLabel
            Spacer()
            providerStatus
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerStatus: some View {
        Text(member.status)
            .font(AtlasFont.mono(9))
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaRow: some View {
        HStack(spacing: 8) {
            metaHashCode
            metaLatency
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaHashCode: some View {
        if let hash = member.responseHash {
            Text("hash \(String(hash.prefix(12)))")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        if let code = member.errorCode {
            Text(code)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaLatency: some View {
        if let latency = member.latencyMs {
            Text("\(latency)ms")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            providerHeader
            metaRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(member.spokenCouncilLine)
        .accessibilityIdentifier(A11yID.reviewCouncilMember(member.provider))
    }
}

// MARK: - Chrome

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        let diverged = AtlasTraceGovernance.councilDiverged(council)
        VStack(alignment: .leading, spacing: 6) {
            councilBlockHeader(diverged: diverged)
            ForEach(council) { member in
                ChangeReviewCouncilMemberRow(member: member)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenCouncilSection(memberCount: council.count, diverged: diverged))
        .accessibilityIdentifier(A11yID.reviewCouncil)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: council.map(\.id))
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlockHeader(diverged: Bool) -> some View {
        HStack(spacing: 8) {
            Text("Conselho")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text("divergência")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel(ChangeReviewJudgment.councilDivergenceLabel)
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContentStack(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let stats {
                governanceStatsLine(stats)
            }
            governanceRevisionsLine(revisions)
            governanceCouncilBlock(council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContent(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        if stats != nil || !revisions.isEmpty || !council.isEmpty {
            let pack = ChangeReviewJudgment.packGovernanceFacts(
                stats: stats,
                revisionCount: revisions.count,
                councilCount: council.count,
                diverged: AtlasTraceGovernance.councilDiverged(council)
            )
            governanceChrome {
                governanceContentStack(
                    stats: stats,
                    revisions: revisions,
                    council: council
                )
            }
            .accessibilityValue(
                (pack.facts + pack.absences.map { "ausência: \($0)" })
                    .joined(separator: "; ")
            )
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceCouncilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        if !council.isEmpty {
            councilBlock(council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceRevisionsLine(_ revisions: [AtlasTraceGovernance.PlanRevision]) -> some View {
        if let last = revisions.last {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .atlasSans(11)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(revisions.count == 1
                     ? "plano v1 arquivado — \(last.humanReason)"
                     : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceStatsLine(_ stats: AtlasTraceGovernance.DiffStats) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plusminus")
                .atlasSans(11)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(stats.headline)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityLabel(ChangeReviewJudgment.spokenDiffStats(stats))
        }
    }
}

// MARK: - Governance / Conselho (C18 · C19 · C21)
// Stats/Revisions → +StatsLine/+RevisionsLine · Council block → +Block.swift
// Chrome → ChangeReviewCouncilSection+Chrome.swift
// Content → ChangeReviewCouncilSection+Content.swift

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        governanceTraceGate
    }
}


extension ChangeReviewGovernanceSection {
    @ViewBuilder
    var governanceTraceGate: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)
            governanceContent(stats: stats, revisions: revisions, council: council)
        }
    }
}

struct ChangeReviewHashWarning: View {
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text(ChangeReviewJudgment.hashWarningLabel)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewJudgment.hashWarningLabel)
        .accessibilityIdentifier(A11yID.reviewHashWarning)
    }
}

// Provider model label — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var providerModelLabel: some View {
        if let model = member.model {
            Text(model)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
