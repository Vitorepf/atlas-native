import Foundation

/// Spoken labels do zoom de artefato — peel de ZoomableArtifactImage (CICLO C).
/// Fala nome, escala atual e ações; silêncio sem inventar dimensões.

enum ArtifactViewerZoomA11y {
    static func spokenImage(name: String, scale: CGFloat) -> String {
        if scale <= 1.01 {
            return "imagem \(name), tamanho normal"
        }
        let pct = Int((scale * 100).rounded())
        return "imagem \(name), ampliada \(pct) por cento"
    }

    static let zoomHint = "pinça para aproximar, arraste quando ampliada, toque duas vezes ou use ações para redefinir"

    static let resetAction = "Redefinir zoom"
}
