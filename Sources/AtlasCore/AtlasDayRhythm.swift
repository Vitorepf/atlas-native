import Foundation

public actor AtlasDayRhythm {
    public struct Windows: Sendable, Equatable {
        public let dayEnd: DateComponents?
        public let dayStart: DateComponents?
        public let sampleDays: Int

        public init(dayEnd: DateComponents?, dayStart: DateComponents?, sampleDays: Int) {
            self.dayEnd = dayEnd
            self.dayStart = dayStart
            self.sampleDays = sampleDays
        }
    }

    public struct DaySummary: Sendable, Equatable {
        public let workspaces: [String]

        public init(workspaces: [String]) {
            self.workspaces = workspaces
        }
    }

    private struct Envelope: Codable {
        var v: Int
        var days: [DayRecord]
    }

    private struct DayRecord: Codable {
        var date: String
        var first: String?
        var last: String?
        var workspaces: [String]

        init(date: String, first: String? = nil, last: String? = nil, workspaces: [String] = []) {
            self.date = date
            self.first = first
            self.last = last
            self.workspaces = workspaces
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            date = try container.decode(String.self, forKey: .date)
            first = try container.decodeIfPresent(String.self, forKey: .first)
            last = try container.decodeIfPresent(String.self, forKey: .last)
            workspaces = try container.decodeIfPresent([String].self, forKey: .workspaces) ?? []
        }
    }

    private let storeURL: URL
    private var days: [String: DayRecord]

    public init(storeURL: URL? = nil) {
        let resolvedURL = storeURL ?? Self.applicationSupportFileURL()
        self.storeURL = resolvedURL
        if let data = try? Data(contentsOf: resolvedURL),
           let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
           envelope.v == 1 {
            self.days = Dictionary(uniqueKeysWithValues: envelope.days.map { ($0.date, $0) })
        } else {
            self.days = [:]
        }
    }

    public static func applicationSupportFileURL(fileManager: FileManager = .default) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return base
            .appendingPathComponent("AtlasNative", isDirectory: true)
            .appendingPathComponent("day-rhythm.v1.json")
    }

    public func recordActivity(workspace: String?, now: Date = .init()) async {
        let key = Self.dateKey(for: now)
        let time = Self.timeKey(for: now)
        var record = days[key] ?? DayRecord(date: key)
        if record.first.flatMap(Self.minutes(from:)) ?? Int.max > Self.minutes(from: time)! {
            record.first = time
        }
        if record.last.flatMap(Self.minutes(from:)) ?? Int.min < Self.minutes(from: time)! {
            record.last = time
        }
        if let safeWorkspace = Self.safeWorkspaceName(workspace),
           !record.workspaces.contains(safeWorkspace) {
            record.workspaces.append(safeWorkspace)
        }
        days[key] = record
        try? persist()
    }

    public func windows(minimumDays: Int = 4, now: Date = .init()) async -> Windows {
        let today = Self.dateKey(for: now)
        let start = Self.dateKey(for: Calendar.current.date(byAdding: .day, value: -13, to: now) ?? now)
        let samples = days.values
            .filter { $0.date >= start && $0.date <= today }
            .filter { Self.minutes(from: $0.first) != nil && Self.minutes(from: $0.last) != nil }
            .sorted { $0.date > $1.date }

        let sampleDays = samples.count
        guard sampleDays >= minimumDays else {
            return Windows(dayEnd: nil, dayStart: nil, sampleDays: sampleDays)
        }

        let recent = Array(samples.prefix(min(sampleDays, 7)))
        let starts = recent.compactMap { Self.minutes(from: $0.first) }
        let ends = recent.compactMap { Self.minutes(from: $0.last) }
        return Windows(
            dayEnd: Self.components(from: Self.median(ends)),
            dayStart: Self.components(from: Self.median(starts)),
            sampleDays: sampleDays
        )
    }

    public func todaySummary(now: Date = .init()) async -> DaySummary {
        let key = Self.dateKey(for: now)
        return DaySummary(workspaces: days[key]?.workspaces ?? [])
    }

    public func reset() async {
        days = [:]
        try? persist()
    }

    private func persist() throws {
        let sortedDays = Array(days.values)
            .sorted { $0.date < $1.date }
            .suffix(14)
        days = Dictionary(uniqueKeysWithValues: sortedDays.map { ($0.date, $0) })
        try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(v: 1, days: Array(sortedDays)))
        try data.write(to: storeURL, options: [.atomic])
    }

    private static func safeWorkspaceName(_ workspace: String?) -> String? {
        guard let workspace else { return nil }
        let trimmed = workspace.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let name = (trimmed as NSString).lastPathComponent
        guard !name.isEmpty, name != "/" else { return nil }
        return name
    }

    private static func dateKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private static func timeKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }

    private static func minutes(from value: String?) -> Int? {
        guard let value else { return nil }
        let parts = value.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute) else { return nil }
        return hour * 60 + minute
    }

    private static func median(_ values: [Int]) -> Int? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private static func components(from minutes: Int?) -> DateComponents? {
        guard let minutes else { return nil }
        return DateComponents(hour: minutes / 60, minute: minutes % 60)
    }
}
