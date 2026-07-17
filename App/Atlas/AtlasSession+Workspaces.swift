import Foundation
import AtlasCore

extension AtlasSession {
    var workspaces: [Workspace] {
        var groups: [String: (name: String, count: Int)] = [:]
        for t in threads {
            guard let w = t.workspace, !w.isEmpty else { continue }
            let base = (w as NSString).lastPathComponent
            let key = base.lowercased()
            var g = groups[key] ?? (name: base, count: 0)
            g.count += 1
            groups[key] = g
        }
        return groups
            .map { Workspace(id: $0.key, name: $0.value.name, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func workspaceFullPath(forKey key: String) -> String? {
        threads.first {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }?.workspace
    }

    func threads(inWorkspace key: String?) -> [AtlasAiThread] {
        guard let key else { return threads }
        return threads.filter {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }
    }
}
