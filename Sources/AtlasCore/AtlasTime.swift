import Foundation

/// Timestamp parsing that mirrors JavaScript's `new Date(str).getTime()`.
///
/// This is gotcha #1 of the whole port (see plano-swift-puro §3.5): Swift's
/// `ISO8601DateFormatter` is strict and, by default, REJECTS fractional seconds.
/// The atlas-server emits both `...T15:41:00Z` and `...T15:41:00.123Z`. If the
/// LWW merge parsed only the strict form, any fractional timestamp would parse
/// as "absent" and silently pick the wrong winner. So: try fractional first,
/// then plain, and mirror JS's `NaN` for anything unparseable.
public enum AtlasTime {
    // Value-type strategies are Sendable and immutable. This keeps parsing
    // synchronous/cheap without sharing mutable ISO8601DateFormatter instances.
    private static let withFractional = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let plain = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    /// Milliseconds since epoch, or `.nan` when the string is nil/empty/unparseable —
    /// exactly like `new Date(str).getTime()` returning `NaN` for an Invalid Date.
    /// NaN then propagates through `>=` comparisons as `false`, so a bad timestamp
    /// never wins the LWW compare (matching the JS behaviour verbatim).
    public static func ms(_ value: String?) -> Double {
        guard let date = date(value) else { return .nan }
        return date.timeIntervalSince1970 * 1000
    }

    /// Data canônica quando o servidor declara um instante público. Diferente
    /// de `Date()` no cliente, este valor sobrevive a reconnect e relaunch.
    public static func date(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        return (try? withFractional.parse(value)) ?? (try? plain.parse(value))
    }
}
