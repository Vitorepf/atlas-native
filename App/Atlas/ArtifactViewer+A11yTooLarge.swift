import Foundation
import AtlasCore

// Too-large preview spoken — peel de ArtifactViewer+A11y.

extension ArtifactViewerA11y {
    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}
