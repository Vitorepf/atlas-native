import AtlasCore

// Cycle 041 fuse → AtlasFailureCopy.swift

/// Copy editorial por `AtlasNetworkFailureKind` — home e conversa compartilham
/// a mesma voz (offline × timeout × recusada × …). Presentation-only.
enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        guard let kind else { return "O servidor está fora de alcance." }
        return networkHeadline(kind: kind) ?? authServerHeadline(kind: kind)
    }
}
