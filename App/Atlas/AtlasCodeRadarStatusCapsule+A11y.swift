import AtlasCore
import SwiftUI

// Spoken labels do radar — peel de AtlasCodeRadarStatusCapsule (CICLO C residual).
// Quiet → AtlasCodeRadarStatusCapsule+A11y+Quiet.swift

extension AtlasCodeRadarStatusCapsule {
    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    func spokenStatus(model: AtlasCodeWorkspaceModel) -> String {
        spokenStatusQuiet(model: model) ?? "atenção, \(model.headline)"
    }
}
