import SwiftUI
import AtlasCore

// Quality line — peel de ExecutionProof+ReplayQuality.
// Flags → ExecutionProof+ReplayQualityFlags.swift

extension ExecutionProof {
    func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }
}
