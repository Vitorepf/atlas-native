import SwiftUI
import UIKit
import AtlasCore

// Preview/zoom → ArtifactViewer.swift · conteúdo → ArtifactSheet+Content.swift.
struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var selectedID: String?
    @State var preview: ArtifactPreviewState = .idle
    @State var loadFinished = false
    @State var mountRevealed = 0

    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
    }
    var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Artefatos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                        dismiss()
                    }
                        .accessibilityLabel("fechar artefatos")
                        .accessibilityHint("volta para a conversa")
                }
            }
            .overlay(alignment: .top) { toast }
            .accessibilityIdentifier(A11yID.artifactsSheet)
            .accessibilityLabel(spokenArtifactsSheetLabel())
            .accessibilityHint("lista e preview só com itens publicados no contrato")
        }
        .task {
            await reviews.refreshChangeReview(traceId: traceId)
            loadFinished = true
            if hasDeliveryProof { await runMountAnimation() }
            else { mountRevealed = deliveryChecks.count }
        }
        .onChange(of: items.map(\.id)) { _, ids in
            if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
                selectedID = ids.first
            }
        }
        .task(id: selected?.id) {
            guard mountComplete, let selected else { return }
            await load(selected)
        }
    }

    @ViewBuilder var toast: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityAddTraits(.isStaticText)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    if reduceMotion { reviews.toast = nil }
                    else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
                }
        }
    }
}
