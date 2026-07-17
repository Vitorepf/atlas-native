import Foundation

// Arena capability row A11yID — peel de A11yID+Arena.

extension A11yID {
    static let arenaCapabilityRowPrefix = "arena-capability-row-"
    static func arenaCapabilityRow(_ capability: String) -> String { arenaCapabilityRowPrefix + capability }
}
