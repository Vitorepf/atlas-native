import SwiftUI
import AtlasCore

// Quality flag/action counts — peel de ExecutionProof+ReplayQualityLine.

extension ExecutionProof {
    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }
}
