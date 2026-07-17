import Foundation
import AtlasCore

/// F6.1: hidratação/persistência do snapshot de leitura — fora do arquivo
/// principal para ConversationModel ficar sob a régua (<800).
extension ConversationModel {
    func hydrateFromCache(threadId: ThreadID) async -> Bool {
        guard let snapshot = await readCache.load(threadId: threadId.rawValue) else {
            showingStaleCache = false
            cacheCapturedAt = nil
            return false
        }
        applyWorkspace(snapshot.workspacePath)
        bubbles = Self.bubbles(from: snapshot.messages)
        cacheCapturedAt = snapshot.capturedAt
        showingStaleCache = true
        loadError = nil
        loadFailureKind = nil
        return true
    }

    func applyWorkspace(_ path: String?) {
        guard let path, !path.isEmpty else { return }
        workspacePath = path
        workspaceName = (path as NSString).lastPathComponent
        workspaceSlug = workspaceName?.lowercased()
    }
}
