import Foundation

// MARK: - Builders do payload (porte de sourceManifest.ts)

public enum RichInputPayloadBuilder {
    /// `manifest-<fnv36>` quando não há id (TS: stableManifestId).
    static func stableManifestId(_ a: RichInputManifestSource) -> String {
        if let id = a.id, !id.isEmpty { return id }
        return "manifest-" + atlasFnv36("\(a.uri ?? "")|\(a.fileName)|\(a.size ?? 0)")
    }

    static func manifestEntry(_ a: RichInputManifestSource, uploadedId: String?,
                              forcedKind: String?) -> AtlasRichInputPayload.ManifestEntry {
        let kind: AtlasAttachmentKind = forcedKind == "image"
            ? .image
            : AtlasAttachmentClassifier.detect(mimeType: a.mimeType, fileName: a.fileName).kind
        return .init(id: stableManifestId(a), kind: kind, fileName: a.fileName,
                     mimeType: a.mimeType, size: (a.size ?? 0) > 0 ? a.size! : 0,
                     uploadedId: uploadedId, sourceHash: nil, source: a.source ?? "app")
    }

    public static func urlAttachment(from detected: AtlasDetectedUrl) -> AtlasRichInputPayload.UrlAttachment {
        let canonicalUrl = detected.kind == "youtube"
            ? (AtlasURLDetector.normalizeYouTubeUrl(detected.url) ?? detected.url)
            : detected.url
        return .init(
            url: canonicalUrl, kind: detected.kind, title: nil, author: nil, durationSec: nil,
            thumbnailUrl: detected.kind == "youtube" && detected.refId != nil
                ? "https://img.youtube.com/vi/\(detected.refId!)/hqdefault.jpg" : nil,
            refId: detected.refId)
    }

    public static func urlAttachments(fromText text: String,
                                      limits: AtlasAttachmentLimits = .canonical) -> [AtlasRichInputPayload.UrlAttachment] {
        AtlasURLDetector.extractUrls(text)
            .prefix(limits.maxUrls)
            .map { urlAttachment(from: AtlasURLDetector.classify($0)) }
    }

    static func urlManifestEntry(_ u: AtlasRichInputPayload.UrlAttachment) -> AtlasRichInputPayload.ManifestEntry {
        .init(id: "url-" + atlasFnv36(u.url), kind: .url, fileName: u.url,
              mimeType: "text/uri-list", size: 0, uploadedId: nil, sourceHash: nil, source: "paste")
    }

    /// Ordem: imagens (na ordem dos ids), depois arquivos, depois URLs —
    /// mesma dos arrays paralelos do envio (buildSourceManifest do TS).
    public static func sourceManifest(
        imageAttachments: [RichInputManifestSource], uploadedImageIds: [String],
        fileAttachments: [RichInputManifestSource], uploadedDocumentIds: [String],
        urlAttachments: [AtlasRichInputPayload.UrlAttachment]
    ) -> [AtlasRichInputPayload.ManifestEntry] {
        var manifest: [AtlasRichInputPayload.ManifestEntry] = []
        for (idx, a) in imageAttachments.enumerated() {
            manifest.append(manifestEntry(a, uploadedId: idx < uploadedImageIds.count ? uploadedImageIds[idx] : nil,
                                          forcedKind: "image"))
        }
        for (idx, a) in fileAttachments.enumerated() {
            manifest.append(manifestEntry(a, uploadedId: idx < uploadedDocumentIds.count ? uploadedDocumentIds[idx] : nil,
                                          forcedKind: "file"))
        }
        for u in urlAttachments { manifest.append(urlManifestEntry(u)) }
        return manifest
    }

    /// buildRichInputPayload do TS: urls derivadas do inputText quando não dadas;
    /// text_blocks vazio por default (server só consome no Forge).
    public static func build(
        imageAttachments: [RichInputManifestSource] = [], uploadedImageIds: [String] = [],
        fileAttachments: [RichInputManifestSource] = [], uploadedDocumentIds: [String] = [],
        inputText: String = "",
        urlAttachments: [AtlasRichInputPayload.UrlAttachment]? = nil,
        textBlocks: [AtlasRichInputPayload.TextBlock] = []
    ) -> AtlasRichInputPayload {
        let urls = urlAttachments ?? Self.urlAttachments(fromText: inputText)
        return AtlasRichInputPayload(
            uploadedImageIds: uploadedImageIds,
            uploadedDocumentIds: uploadedDocumentIds,
            textBlocks: textBlocks,
            urlAttachments: urls,
            sourceManifest: sourceManifest(
                imageAttachments: imageAttachments, uploadedImageIds: uploadedImageIds,
                fileAttachments: fileAttachments, uploadedDocumentIds: uploadedDocumentIds,
                urlAttachments: urls))
    }

    /// Regra compact ÚNICA (resolve compactRichInput desktop vs hasRichInputPayload
    /// mobile): o payload só existe se uma das 4 listas REAIS tem item —
    /// source_manifest sozinho NÃO conta.
    public static func compact(_ p: AtlasRichInputPayload) -> AtlasRichInputPayload? {
        let empty = p.uploadedImageIds.isEmpty && p.uploadedDocumentIds.isEmpty
            && p.textBlocks.isEmpty && p.urlAttachments.isEmpty
        return empty ? nil : p
    }
}
