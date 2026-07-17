import Foundation
#if canImport(ActivityKit)
import ActivityKit

// Contrato da Live Activity do turno — COMPARTILHADO app ↔ widget extension.
// ContentState → AtlasTurnAttributes+ContentState.swift
struct AtlasTurnAttributes: ActivityAttributes {
    var threadTitle: String
    var threadKey: String
}
#endif
