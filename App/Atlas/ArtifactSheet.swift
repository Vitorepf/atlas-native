import SwiftUI
import AtlasCore

// WAVE-013 fused ArtifactSheet.swift

// --- ArtifactSheet+A11y+Available.swift ---
extension ArtifactSheet {
    func spokenArtifactsSheetAvailableLabel(_ artifacts: AtlasTraceArtifacts) -> String {
        switch artifacts.state {
        case .unavailable:
            return "artefatos da execução indisponíveis"
        case .available:
            let n = items.count
            if n == 0 { return "artefatos da execução, sem itens publicados" }
            return "artefatos da execução, \(n) item\(n == 1 ? "" : "s")"
        }
    }
}

// --- ArtifactSheet+A11y+Load.swift ---
extension ArtifactSheet {
    func spokenArtifactsSheetLoadLabel() -> String? {
        if !loadFinished, artifacts == nil {
            return "artefatos da execução, consultando"
        }
        if loadFinished, artifacts == nil {
            return "artefatos da execução, indisponível"
        }
        return nil
    }
}

// --- ArtifactSheet+A11y.swift ---
extension ArtifactSheet {
    func spokenArtifactsSheetLabel() -> String {
        if let load = spokenArtifactsSheetLoadLabel() { return load }
        guard let artifacts else { return "artefatos da execução" }
        return spokenArtifactsSheetAvailableLabel(artifacts)
    }
}

// --- ArtifactSheet+Chrome+A11y.swift ---
extension ArtifactSheet {
    func artifactSheetA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.artifactsSheet)
            .accessibilityLabel(spokenArtifactsSheetLabel())
            .accessibilityHint("lista e preview só com itens publicados no contrato")
    }
}

// --- ArtifactSheet+Chrome+Toolbar.swift ---
extension ArtifactSheet {
    func artifactSheetToolbar<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Artefatos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar artefatos",
                        spokenHint: "volta para a conversa",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .overlay(alignment: .top) { toast }
    }
}

// --- ArtifactSheet+Chrome.swift ---
extension ArtifactSheet {
    func artifactSheetChrome<Content: View>(_ content: Content) -> some View {
        artifactSheetA11y(artifactSheetToolbar(content))
    }
}

// --- ArtifactSheet+Empty.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var emptyOrUnavailable: some View {
        if !loadFinished, artifacts == nil {
            TraceEvidenceLoading(text: "consultando artefatos…", reduceMotion: reduceMotion)
        } else if loadFinished, artifacts == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar artefatos.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.artifactsLoadFailure,
                spoken: "não foi possível consultar artefatos"
            )
        } else {
            artifactsUnavailable
        }
    }
}

// --- ArtifactSheet+EmptyGate+Predicate.swift ---
extension ArtifactSheet {
    var showsEmptyOrUnavailable: Bool {
        (!loadFinished && artifacts == nil)
            || (loadFinished && artifacts == nil)
            || artifacts?.state == .unavailable
            || items.isEmpty
    }
}

// --- ArtifactSheet+EmptyGate+View.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var emptyVisualizable: some View {
        Text("nenhum artefato visualizável")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.artifactsEmpty)
            .accessibilityLabel("sem artefatos visualizáveis nesta execução")
    }
}

// --- ArtifactSheet+NavigationShell.swift ---
extension ArtifactSheet {
    var artifactNavigationShell: some View {
        NavigationStack {
            artifactSheetChrome(
                ZStack {
                    AtlasTheme.bg.ignoresSafeArea()
                    content
                }
            )
        }
    }
}

// --- ArtifactSheet.swift ---
struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var selectedID: String?
    @State var preview: ArtifactPreviewState = .idle
    @State var loadFinished = false
    @State var mountRevealed = 0

    var body: some View {
        artifactSheetLifecycle(artifactNavigationShell)
    }
}

