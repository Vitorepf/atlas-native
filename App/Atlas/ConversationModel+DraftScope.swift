import Foundation
import AtlasCore

@MainActor
extension ConversationModel {
    func adoptDraftScope(_ canonicalScope: String) {
        guard canonicalScope != draftScope else { return }
        let current = draftText
        Self.saveDraft("", scope: draftScope)
        draftScope = canonicalScope
        if current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draftText = Self.loadDraft(scope: canonicalScope)
        } else {
            Self.saveDraft(current, scope: canonicalScope)
        }
        if let threadId { lastVisitAt = Self.lastVisitDate(threadId: threadId.rawValue) }
    }
}
