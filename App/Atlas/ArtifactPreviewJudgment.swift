import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive artifact preview pane face (WAVE-058).
enum ArtifactPreviewFace: Equatable {
    case idle
    case loading
    case loaded(kind: String, name: String)
    case tooLarge(name: String, bytes: Int)
    case failed(String)

    var productWord: String {
        switch self {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .tooLarge: return "too_large"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .idle:
            return "preview ocioso"
        case .loading:
            return "carregando preview"
        case .loaded(let kind, let name):
            return "preview \(kind) \(name)"
        case .tooLarge(let name, let bytes):
            return ArtifactViewerA11y.spokenTooLarge(name: name, bytes: bytes)
        case .failed(let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return "preview falhou" }
            return "preview falhou, \(trimmed)"
        }
    }
}

// MARK: - Judgment

/// Pure artifact preview grammar — face · spoken · pack.
enum ArtifactPreviewJudgment {

    static func face(
        _ preview: ArtifactPreviewState,
        selectedName: String? = nil
    ) -> ArtifactPreviewFace {
        switch preview {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .loaded(let item, _):
            return .loaded(
                kind: ArtifactViewer.kindLabel(item.kind),
                name: item.name
            )
        case .tooLarge(let bytes):
            return .tooLarge(name: selectedName ?? "artefato", bytes: bytes)
        case .failed(let message):
            return .failed(message)
        }
    }

    static func spokenPane(
        _ preview: ArtifactPreviewState,
        selectedName: String? = nil
    ) -> String {
        face(preview, selectedName: selectedName).spokenFace
    }

    /// Loaded content spoken — prefers rich kind lines from ArtifactViewerA11y.
    static func spokenLoaded(
        item: AtlasTraceArtifacts.Item,
        content: AtlasArtifactContent
    ) -> String {
        _ = content
        return ArtifactViewerA11y.spokenPreview(item: item)
    }

    static func packFacts(
        preview: ArtifactPreviewState,
        selected: AtlasTraceArtifacts.Item?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(preview, selectedName: selected?.name)
        facts.append("artifact_preview_face: \(face.productWord)")
        if let selected {
            facts.append("preview_item: \(selected.name)")
            facts.append("preview_kind: \(selected.kind.rawValue)")
            facts.append("preview_bytes: \(selected.byteSize)")
        } else {
            absences.append("nenhum artefato selecionado no preview")
        }
        switch face {
        case .idle:
            absences.append("preview ocioso")
        case .loading:
            absences.append("preview carregando")
        case .loaded:
            facts.append("preview_ready: true")
        case .tooLarge(_, let bytes):
            facts.append("preview_too_large_bytes: \(bytes)")
            absences.append("conteúdo não renderizado — tamanho acima do limite local")
        case .failed(let message):
            absences.append("preview falhou")
            if !message.isEmpty { facts.append("preview_error: \(message)") }
        }
        return (facts, absences)
    }
}
