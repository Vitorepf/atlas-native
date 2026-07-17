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
        if let fastPath = parsePlainZuluFastPath(value) { return fastPath }
        return (try? withFractional.parse(value)) ?? (try? plain.parse(value))
    }

    private static func parsePlainZuluFastPath(_ value: String) -> Date? {
        let bytes = Array(value.utf8)
        guard bytes.count == 20,
              bytes[4] == UInt8(ascii: "-"),
              bytes[7] == UInt8(ascii: "-"),
              bytes[10] == UInt8(ascii: "T"),
              bytes[13] == UInt8(ascii: ":"),
              bytes[16] == UInt8(ascii: ":"),
              bytes[19] == UInt8(ascii: "Z"),
              let year = decimal(bytes, 0, 4),
              let month = decimal(bytes, 5, 2),
              let day = decimal(bytes, 8, 2),
              let hour = decimal(bytes, 11, 2),
              let minute = decimal(bytes, 14, 2),
              let second = decimal(bytes, 17, 2),
              isValidDate(year: year, month: month, day: day),
              (0..<24).contains(hour),
              (0..<60).contains(minute),
              (0..<60).contains(second)
        else {
            return nil
        }

        let days = daysSinceUnixEpoch(year: year, month: month, day: day)
        let seconds = days * 86_400 + hour * 3_600 + minute * 60 + second
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }

    private static func decimal(_ bytes: [UInt8], _ start: Int, _ count: Int) -> Int? {
        var value = 0
        for index in start..<(start + count) {
            let byte = bytes[index]
            guard (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte) else { return nil }
            value = value * 10 + Int(byte - UInt8(ascii: "0"))
        }
        return value
    }

    private static func isValidDate(year: Int, month: Int, day: Int) -> Bool {
        guard (1...12).contains(month) else { return false }
        return (1...daysInMonth(year: year, month: month)).contains(day)
    }

    private static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 2:
            return isLeapYear(year) ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    private static func isLeapYear(_ year: Int) -> Bool {
        (year.isMultiple(of: 4) && !year.isMultiple(of: 100)) || year.isMultiple(of: 400)
    }

    private static func daysSinceUnixEpoch(year: Int, month: Int, day: Int) -> Int {
        let adjustedYear = year - (month <= 2 ? 1 : 0)
        let era = (adjustedYear >= 0 ? adjustedYear : adjustedYear - 399) / 400
        let yearOfEra = adjustedYear - era * 400
        let shiftedMonth = month + (month > 2 ? -3 : 9)
        let dayOfYear = (153 * shiftedMonth + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    /// Relógio canônico de duração ativa (ms → m:ss ou h:mm:ss). Usado em Lock
    /// Screen, widgets, cockpit e handoff — uma voz, zero cópias locais.
    public static func formatActiveDuration(milliseconds: Int) -> String {
        let s = max(0, milliseconds / 1000)
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }
}
