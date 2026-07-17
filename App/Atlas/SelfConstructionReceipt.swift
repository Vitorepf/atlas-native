import SwiftUI
import AtlasCore

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }

    /// Merge só quando o servidor publica `merge_performed` e hash não vazio.
    var hasMergeProof: Bool {
        cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
    }
}

// Copy → SelfConstructionReceipt+Copy.swift
