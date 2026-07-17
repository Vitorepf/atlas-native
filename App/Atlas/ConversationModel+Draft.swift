import Foundation
import AtlasCore

/// Rascunho por escopo, visita por thread e preferência de esforço — fora do
/// shell principal para ConversationModel ficar sob a régua (<200).
extension ConversationModel {
    func cycleEffort() {
        effort = effort.next
        UserDefaults.standard.set(effort.rawValue, forKey: Self.effortPreferenceKey)
    }

    func updateDraft(_ value: String) {
        draftText = value
        Self.saveDraft(value, scope: draftScope)
    }

    func markThreadVisited() {
        guard let threadId else { return }
        Self.markVisited(threadId: threadId.rawValue)
    }

    static func lastVisitDate(threadId: String) -> Date? {
        UserDefaults.standard.object(forKey: visitedPrefix + threadId) as? Date
    }

    static func hasNewerContent(_ thread: AtlasAiThread) -> Bool {
        guard let last = AtlasTime.date(thread.lastMessageAt ?? thread.updatedAt) else { return false }
        guard let visit = lastVisitDate(threadId: thread.id) else { return thread.messageCount > 0 }
        return last > visit
    }

    static func loadDraft(scope: String) -> String {
        UserDefaults.standard.string(forKey: draftPrefix + scope) ?? ""
    }

    static func saveDraft(_ value: String, scope: String) {
        let key = draftPrefix + scope
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    static func markVisited(threadId: String) {
        UserDefaults.standard.set(Date(), forKey: visitedPrefix + threadId)
    }
}
