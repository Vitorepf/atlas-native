import Foundation

/// Fast path para `…T15:41:00Z` sem fração — peel de AtlasTime.
extension AtlasTime {
    static func parsePlainZuluFastPath(_ value: String) -> Date? {
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

    static func decimal(_ bytes: [UInt8], _ start: Int, _ count: Int) -> Int? {
        var value = 0
        for index in start..<(start + count) {
            let byte = bytes[index]
            guard (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte) else { return nil }
            value = value * 10 + Int(byte - UInt8(ascii: "0"))
        }
        return value
    }

    static func isValidDate(year: Int, month: Int, day: Int) -> Bool {
        guard (1...12).contains(month) else { return false }
        return (1...daysInMonth(year: year, month: month)).contains(day)
    }

    static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 2:
            return isLeapYear(year) ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    static func isLeapYear(_ year: Int) -> Bool {
        (year.isMultiple(of: 4) && !year.isMultiple(of: 100)) || year.isMultiple(of: 400)
    }

    static func daysSinceUnixEpoch(year: Int, month: Int, day: Int) -> Int {
        let adjustedYear = year - (month <= 2 ? 1 : 0)
        let era = (adjustedYear >= 0 ? adjustedYear : adjustedYear - 399) / 400
        let yearOfEra = adjustedYear - era * 400
        let shiftedMonth = month + (month > 2 ? -3 : 9)
        let dayOfYear = (153 * shiftedMonth + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }
}
