import Foundation
import AtlasCore

// Tests spoken — peel de ChangeReviewSections+A11y.
// Decided/toast → ChangeReviewSections+A11yToast.swift

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
}
