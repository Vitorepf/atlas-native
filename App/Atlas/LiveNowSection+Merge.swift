import Foundation
import AtlasCore

/// Merge local+remote sem duplicar thread — peel de LiveNowSection (régua ≤100).

extension LiveNowSection {
    static func merged(local: [LiveSessionSnapshot], remote: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        var seenThreads = Set(local.compactMap { $0.threadId?.rawValue })
        var seenRemoteIDs: Set<String> = []
        let filteredRemote = remote.filter { session in
            if let thread = session.threadId?.rawValue {
                guard !seenThreads.contains(thread) else { return false }
                seenThreads.insert(thread)
                return true
            }
            return seenRemoteIDs.insert(session.id).inserted
        }
        return local + filteredRemote
    }
}
