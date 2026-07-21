import SwiftUI
import AtlasCore

// WAVE-147 density peel

extension AtlasCodeView {
    func codeScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(NavigationInteractivePopEnabler())
            .accessibilityIdentifier(A11yID.codeScreen)
            .accessibilityLabel(spokenCodeScreenLabel())
            .accessibilityValue(graphScreenFace.productWord)
            .accessibilityHint(Self.codeScreenHint)
            .toolbar { codeToolbar }
            .safeAreaInset(edge: .top, spacing: 0) {
                repoSwitcher
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
                    .padding(.bottom, 6)
            }
            .sheet(isPresented: $showsRepoPicker) {
                AtlasCodeRepoPickerSheet(
                    client: session.client,
                    currentRepo: model.repo
                ) { slug in
                    showsRepoPicker = false
                    guard slug != model.repo else { return }
                    Task { await switchToRepo(slug) }
                }
            }
            .task { if model.phase == .idle { await model.load() } }
            .task { await mirrorModel.refresh() }
            // Aquece a frota enquanto o grafo carrega — picker abre instantâneo.
            .task {
                let warmer = AtlasCodeWorkspaceModel(client: session.client)
                await warmer.loadStructure()
            }
            // WAVE-028: default attention slice once scan is known (operator override freezes).
            .onChange(of: model.phase) { _, phase in
                if case .loaded = phase {
                    applyGraphJudgmentDefaultIfNeeded()
                }
            }
            .onChange(of: model.scanState) { _, _ in
                applyGraphJudgmentDefaultIfNeeded()
            }
    }

    func applyGraphJudgmentDefaultIfNeeded() {
        guard !graphFilterTouchedByOperator else { return }
        guard case .loaded = model.phase else { return }
        let next = AtlasCodeGraphJudgment.defaultFilter(
            scan: model.scanState,
            violatingSignalCount: model.violations?.violations.count ?? 0
        )
        if graphStateFilter != next {
            graphStateFilter = next
        }
    }
}

extension AtlasCodeView {
    /// Swipe-focus ou resposta da pílula: o resto do mapa recua.
    func commitRowIsDimmed(_ node: AtlasCodeGraphNode) -> Bool {
        if let focus = askFocusNode {
            return focus.hash != node.hash
        }
        return !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
    }
}
