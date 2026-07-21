import AtlasCore

// Preview state — peel de ArtifactSheet+PreviewLoad.

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
}
