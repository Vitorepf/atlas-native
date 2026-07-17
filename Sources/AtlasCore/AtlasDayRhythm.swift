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

    private let storeURL: URL
    private var days: [String: AtlasDayRhythmDayRecord]

    public init(storeURL: URL? = nil) {
        let resolvedURL = storeURL ?? Self.applicationSupportFileURL()
        self.storeURL = resolvedURL
        if let data = try? Data(contentsOf: resolvedURL),
           let envelope = try? JSONDecoder().decode(AtlasDayRhythmEnvelope.self, from: data),
           envelope.v >= 1 {
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
        var record = days[key] ?? AtlasDayRhythmDayRecord(date: key)
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
        let data = try JSONEncoder().encode(AtlasDayRhythmEnvelope(v: 1, days: Array(sortedDays)))
        try data.write(to: storeURL, options: [.atomic])
    }
}
