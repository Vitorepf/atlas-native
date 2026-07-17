import Foundation
import AtlasCore

// Tests/decided spoken — peel de ChangeReviewSections+A11y.

extension ChangeReviewSectionsA11y {
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

    static func spokenToast(_ text: String) -> String {
        "aviso, \(text)"
    }
}
