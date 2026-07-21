import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ArtifactJudgments fused

// MARK: - ArtifactListJudgment

// MARK: - Types

/// Exclusive artifact list chrome face (WAVE-092).
/// Evidence sheet face stays WAVE-041; preview pane stays WAVE-058.
enum ArtifactListFace: Equatable {
    case silence
    case list(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "lista de artefatos vazia"
        case .list(let n):
            let noun = n == 1 ? "item" : "itens"
            return "lista de artefatos, \(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure artifact list/row grammar — list face · row spoken · empty · close · pack.
enum ArtifactListJudgment {

    static let closeLabel = "fechar artefatos"
    static let closeHint = "volta para a conversa"
    static let sheetHint = "lista e preview só com itens publicados no contrato"
    static let emptyVisualizableLabel = "sem artefatos visualizáveis nesta execução"
    static let emptyVisualizableCopy = "nenhum artefato visualizável"
    static let loadFailSpoken = "não foi possível consultar artefatos"
    static let selectedHint = "selecionado no preview"
    static let openHint = "abre o preview deste artefato"

    // MARK: Face

    static func listFace(itemCount: Int) -> ArtifactListFace {
        itemCount <= 0 ? .silence : .list(itemCount)
    }

    // MARK: Rank (WAVE-041)

    static func rankItems(_ items: [AtlasTraceArtifacts.Item]) -> [AtlasTraceArtifacts.Item] {
        ArtifactJudgment.rankItems(items)
    }

    // MARK: Spoken

    static func spokenList(itemCount: Int) -> String {
        listFace(itemCount: itemCount).spokenFace
    }

    static func spokenRow(
        name: String,
        byteSize: Int,
        kind: AtlasTraceArtifacts.Item.Kind,
        selected: Bool
    ) -> String {
        var parts = [
            name,
            ArtifactViewer.byteLabel(byteSize),
            ArtifactViewer.kindLabel(kind)
        ]
        if selected { parts.append("selecionado") }
        return parts.joined(separator: ", ")
    }

    static func spokenRow(
        item: AtlasTraceArtifacts.Item,
        selected: Bool
    ) -> String {
        spokenRow(
            name: item.name,
            byteSize: item.byteSize,
            kind: item.kind,
            selected: selected
        )
    }

    static func rowHint(selected: Bool) -> String {
        selected ? selectedHint : openHint
    }

    static func spokenEmptyVisualizable() -> String {
        emptyVisualizableLabel
    }

    // MARK: Pack

    static func packFacts(
        items: [AtlasTraceArtifacts.Item],
        selectedID: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = listFace(itemCount: items.count)
        facts.append("artifact_list_face: \(face.productWord)")
        facts.append("artifact_list_count: \(items.count)")
        switch face {
        case .silence:
            absences.append("lista de artefatos visualizáveis vazia")
        case .list:
            let ranked = rankItems(items)
            for item in ranked.prefix(6) {
                let sel = item.id == selectedID ? " · selected" : ""
                facts.append("artifact_row: \(item.kind.rawValue) · \(item.name)\(sel)")
            }
            if let selectedID, !items.contains(where: { $0.id == selectedID }) {
                absences.append("selectedID não está na lista publicada")
            }
        }
        return (facts, absences)
    }
}
// MARK: - ArtifactPreviewChrome

extension ArtifactViewer {
    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var diffPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(String(decoding: content.data, as: UTF8.self))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 360)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArtifactPreviewJudgment.spokenPreview(item: item))
        .accessibilityHint("arraste horizontalmente para ler o diff")
    }
}

extension ArtifactViewer {
    static func kindLabelImageMarkdown(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        switch kind {
        case .image: return "imagem"
        case .markdown: return "markdown"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabelDocument(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        if let imageMd = kindLabelImageMarkdown(kind) { return imageMd }
        switch kind {
        case .text: return "texto"
        case .diff: return "diff"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        kindLabelDocument(kind) ?? "arquivo"
    }
}

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group { previewSwitch }
    }
}

extension ArtifactPreviewContent {
    var imageDecodeFailure: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
        )
        .accessibilityLabel(
            ArtifactPreviewJudgment.spokenDecodeFailure(name: item.name, bytes: item.byteSize)
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var imagePreviewBranch: some View {
        if let image = UIImage(data: content.data) {
            ZoomableArtifactImage(image: image, name: item.name)
        } else {
            imageDecodeFailure
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
        switch item.kind {
        case .image:
            imagePreviewBranch
        default:
            textishPreview
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishDocumentPreview: some View {
        switch item.kind {
        case .markdown, .text:
            textishMarkdownPreview(content.data)
        case .diff:
            diffPreview
        default:
            EmptyView()
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishFilePreview: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    func textishMarkdownPreview(_ content: Data) -> some View {
        AtlasMarkdownView(text: String(decoding: content, as: UTF8.self), streaming: false)
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text, .diff:
            textishDocumentPreview
        case .file:
            textishFilePreview
        default:
            EmptyView()
        }
    }
}
