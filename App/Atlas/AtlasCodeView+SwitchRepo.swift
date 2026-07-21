import SwiftUI
import AtlasCore

// Troca de repo in-place — peel de AtlasCodeView.
// Sem remount da NavigationStack: a lentidão era destruir @State + 4 GETs.

extension AtlasCodeView {
    func switchToRepo(_ slug: String) async {
        guard slug != model.repo else { return }
        selectedNode = nil
        showsHealReceipt = false
        showsAskCard = false
        whyFileTarget = nil
        askThreadId = nil
        askDraft = ""
        askFocusNode = nil
        graphStateFilter = .all

        model.adoptRepo(slug)
        provenanceModel.adoptRepo(slug)
        mirrorModel.adoptRepo(slug)
        askModel.adoptRepo(slug) // also clears sheetFocusLegend

        async let graphLoad: Void = model.load()
        async let mirrorLoad: Void = mirrorModel.refresh()
        await graphLoad
        await mirrorLoad
    }
}
