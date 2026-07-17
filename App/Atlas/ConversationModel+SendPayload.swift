import SwiftUI
import AtlasCore

@MainActor
extension ConversationModel {
    func buildSendTurnInput(
        originalText: String,
        trimmed: String,
        effort: AtlasComputeEffort,
        longMessage: AtlasPreparedLongMessage,
        fields: RichInputInteractionFields?
    ) async -> CreateAiInteractionInput {
        #if DEBUG
        let proofProvider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"]
        #else
        let proofProvider: String? = nil
        #endif

        var wireText = trimmed
        var operatorText: String?
        if let collectFacts = turnFacts,
           let facts = await collectFacts(originalText),
           !facts.isEmpty {
            wireText = facts + "\n\n" + trimmed
            operatorText = originalText
        }

        let workspace = workspaceSlug.map {
            TurnPayloadBuilder.Workspace(slug: $0, name: workspaceName, path: workspacePath)
        }
        let payload = TurnPayloadBuilder.build(
            taskKind: taskKind,
            effort: effort,
            workspace: workspace,
            longMessage: longMessage.metadata,
            operatorText: operatorText
        )
        return CreateAiInteractionInput(
            inputText: wireText,
            clientId: UUID().uuidString.lowercased(),
            threadId: threadId?.rawValue,
            newThread: threadId == nil ? true : nil,
            agentSlug: proofProvider == nil ? nil : "atlas",
            provider: proofProvider,
            sourceType: "app",
            payload: atlasMobileInteractionPayload(base: payload),
            uploadedImages: fields?.uploadedImages.isEmpty == false ? fields?.uploadedImages : nil,
            uploadedDocuments: fields?.uploadedDocuments.isEmpty == false ? fields?.uploadedDocuments : nil,
            richInputPayload: fields?.richInputPayload
        )
    }
}
