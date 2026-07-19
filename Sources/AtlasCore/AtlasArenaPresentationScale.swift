import Foundation

/// Human-facing projection for Arena scores.
///
/// Wire and persistence contracts remain normalized in `0...1`; the iPhone
/// presents the same fact on a `0...10` scale. Values are intentionally not
/// clamped so a contract violation stays observable instead of being hidden.
public enum AtlasArenaPresentationScale: Sendable {
    public static let maximum = 10.0

    public static func score(_ normalized: Double?) -> Double? {
        normalized.map { $0 * maximum }
    }

    public static func delta(_ normalized: Double?) -> Double? {
        normalized.map { $0 * maximum }
    }
}
