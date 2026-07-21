import SwiftUI
import AtlasCore

enum ArenaPremiumIconRole {
    case compact
    case standard
    case hero

    var pointSize: CGFloat {
        switch self {
        case .compact: 12
        case .standard: 17
        case .hero: 28
        }
    }

    var box: CGFloat {
        switch self {
        case .compact: 16
        case .standard: 24
        case .hero: 68
        }
    }
}

/// The only renderer for symbols inside the Arena surface.
struct ArenaPremiumIcon: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    var role: ArenaPremiumIconRole = .standard

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: role.pointSize, weight: .medium))
            .foregroundStyle(tone.color)
            .frame(width: role.box, height: role.box, alignment: .center)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumChevron: View {
    var body: some View {
        ArenaPremiumIcon(
            symbol: ArenaPremiumIconography.disclosure,
            tone: .muted,
            role: .compact
        )
        .accessibilityHidden(true)
    }
}

enum ArenaPremiumIconography {
    static let action = "play.fill"
    static let add = "plus"
    static let alerts = "exclamationmark.triangle"
    static let blocked = "lock"
    static let comparison = "arrow.right"
    static let coverage = "checkmark.seal"
    static let disclosure = "chevron.right"
    static let execution = "list.bullet.rectangle"
    static let next = "calendar.badge.clock"
    static let plan = "list.bullet.rectangle"
    static let queue = "tray.full"
    static let stop = "stop.fill"

    static func run(_ status: AtlasArenaRunStatus) -> String {
        switch status {
        case .queued: "clock"
        case .running: "play.circle"
        case .stopping: "hourglass"
        case .stopped: "stop.circle"
        case .completed: "checkmark.circle"
        case .failed: "exclamationmark.triangle"
        case .unknown: "questionmark.circle"
        }
    }

    static func planStatus(_ status: AtlasArenaRunStatus?) -> String {
        guard let status else { return "circle" }
        return run(status)
    }

    static func suite(_ suite: String) -> String {
        switch suite {
        case "terminal_bench": "terminal"
        case "bfcl": "wrench.and.screwdriver"
        case "inspect_evals": "arrow.triangle.2.circlepath"
        case "tau2_bench": "function"
        case "live_code_bench", "swe_bench_live":
            "chevron.left.forwardslash.chevron.right"
        default: "diamond"
        }
    }
}
