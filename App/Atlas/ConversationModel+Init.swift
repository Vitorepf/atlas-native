import SwiftUI
import AtlasCore
import AtlasImaging

// Init + wiring — peel de ConversationModel (régua <110).

extension ConversationModel {
    init(
        client: AtlasClient,
        threadId: ThreadID?,
        readCache: ThreadReadCache = ThreadReadCache(fileURL: ThreadReadCache.applicationSupportFileURL())
    ) {
        self.client = client
        self.reviews = ChangeReviewModel(client: client)
        self.threadId = threadId
        self.engine = AtlasRichInputEngine(transport: client, installSalt: AtlasInstallationIdentity.id)
        self.outbox = InteractionOutbox(fileURL: InteractionOutbox.applicationSupportFileURL())
        self.queueStore = QueuedFollowUpStore(fileURL: QueuedFollowUpStore.applicationSupportFileURL())
        self.readCache = readCache
        self.queueScope = threadId.map { "thread:\($0.rawValue)" } ?? "local:\(UUID().uuidString.lowercased())"
        self.draftScope = self.queueScope
        self.effort = AtlasComputeEffort(
            rawValue: UserDefaults.standard.string(forKey: Self.effortPreferenceKey) ?? ""
        ) ?? .auto
        self.draftText = Self.loadDraft(scope: draftScope)
        if let threadId {
            self.lastVisitAt = Self.lastVisitDate(threadId: threadId.rawValue)
        }
        self.reviews.onTraceUpdated = { [weak self] traceId, trace in
            guard let self else { return }
            for bubble in self.bubbles where bubble.traceId == traceId {
                self.applyExecution(bubble.id, trace)
            }
        }
    }
}
