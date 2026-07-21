import AtlasCore
import SwiftUI

// Quiet/unknown radar spoken — peel de AtlasCodeRadarStatusCapsule+A11y.

extension AtlasCodeRadarStatusCapsule {
    func spokenStatusQuiet(model: AtlasCodeWorkspaceModel) -> String? {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        default:
            return nil
        }
    }
}
