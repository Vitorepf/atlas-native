import Foundation
import AtlasCore

/// Rascunho por escopo, visita por thread e preferência de esforço — fora do
/// shell principal para ConversationModel ficar sob a régua (<200).
extension ConversationModel {
    func cycleEffort() {
        setEffort(effort.next)
    }

    /// Único ponto de persistência do esforço — a casca (EffortSheet) chama
    /// isto; storage na View é violação de boundary.
    func setEffort(_ newEffort: AtlasComputeEffort) {
        effort = newEffort
        UserDefaults.standard.set(newEffort.rawValue, forKey: Self.effortPreferenceKey)
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
        // "Novo" é novidade RECENTE (7 dias): acervo antigo nunca aberto é
        // arquivo, não notícia — 100 badges dourados = zero informação.
        guard last > Date().addingTimeInterval(-7 * 86_400) else { return false }
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
