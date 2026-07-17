import Foundation
import AtlasCore

/// Spoken labels das seções remanescentes — peel de ChangeReviewSections+Chrome (CICLO C).
/// Só campos publicados pelo servidor; score/decisão verbatim; toast = texto real.
/// Tests/decided → ChangeReviewSections+A11yDecided.swift

enum ChangeReviewSectionsA11y {
    static func spokenCaption(_ text: String) -> String {
        text.lowercased()
    }

    static func spokenRunHeader(run: AtlasTraceChangeReview.Run) -> String {
        var parts = [run.decision ?? run.status ?? "revisão"]
        if let finished = run.finishedAt?.nonEmpty { parts.append("concluída \(finished)") }
        if let score = run.score { parts.append("pontuação \(score)") }
        return parts.joined(separator: ", ")
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
}
