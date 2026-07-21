import Foundation
import AtlasCore
import SwiftUI

// WAVE-132 ChangeReview chrome spoken (run/patch/gov/section)

extension ChangeReviewJudgment {
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
