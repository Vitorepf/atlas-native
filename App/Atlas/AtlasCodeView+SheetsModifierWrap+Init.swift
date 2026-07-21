import SwiftUI
import AtlasCore

// Sheets modifier init — peel de AtlasCodeView+SheetsModifierWrap.

extension View {
    func atlasCodeSheetsModifierInit(
        session: AtlasSession,
        model: AtlasCodeModel,
        provenanceModel: AtlasCodeProvenanceModel,
        askModel: AtlasCodeAskModel,
        selectedNode: Binding<AtlasCodeGraphNode?>,
        showsHealReceipt: Binding<Bool>,
        showsAskCard: Binding<Bool>,
        whyFileTarget: Binding<AtlasCodeView.WhyFileTarget?>,
        askThreadId: Binding<ThreadID?>,
        askDraft: Binding<String>,
        onProvenanceAsk: @escaping (AtlasCodeGraphNode) -> Void
    ) -> some View {
        modifier(AtlasCodeSheetsModifier(
            session: session,
            model: model,
            provenanceModel: provenanceModel,
            askModel: askModel,
            selectedNode: selectedNode,
            showsHealReceipt: showsHealReceipt,
            showsAskCard: showsAskCard,
            whyFileTarget: whyFileTarget,
            askThreadId: askThreadId,
            askDraft: askDraft,
            onProvenanceAsk: onProvenanceAsk
        ))
    }
}
