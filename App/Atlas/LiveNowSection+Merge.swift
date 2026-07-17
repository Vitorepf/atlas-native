import Foundation
import AtlasCore

/// Merge local+remote sem duplicar thread — peel de LiveNowSection (régua ≤100).
/// RemoteFilter → LiveNowSection+Merge+RemoteFilter.swift

extension LiveNowSection {
    static func merged(local: [LiveSessionSnapshot], remote: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        local + filteredRemote(local: local, remote: remote)
    }
}
