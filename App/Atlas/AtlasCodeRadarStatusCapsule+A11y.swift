import AtlasCore
import SwiftUI

// Spoken labels do radar — peel de AtlasCodeRadarStatusCapsule (CICLO C residual).

extension AtlasCodeRadarStatusCapsule {
    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    func spokenStatus(model: AtlasCodeWorkspaceModel) -> String {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        case .violating:
            return "atenção, \(model.headline)"
        }
    }
}
