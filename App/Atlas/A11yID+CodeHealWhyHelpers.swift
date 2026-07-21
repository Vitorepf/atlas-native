import Foundation

// Code heal/why helpers — peel de A11yID+CodeHelpers.

extension A11yID {
    static func codeHealStep(_ index: Int) -> String { codeHealStepPrefix + String(index) }
    static func whyRow(_ index: Int) -> String { whyRowPrefix + String(index) }
    static func whyFileRow(_ index: Int) -> String { whyFileRowPrefix + String(index) }
}
