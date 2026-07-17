import Foundation
import AtlasCore

public func runAtlasDayRhythmChecks(_ check: (String, Bool) -> Void) async {
    await checkMedian7Days(check)
    await checkColdStartNil(check)
    await checkIgnoresEmptyDays(check)
    await checkTodayWorkspacesDedup(check)
    await checkPersistenceRoundtrip(check)
    await checkFutureVersionLoadKeepsKnownFields(check)
    await checkCap14Days(check)
    await checkTimezoneChangeSafe(check)
    await checkWindowsMinutesToComponents(check)
}

private func makeRhythmURL(_ name: String = UUID().uuidString) -> URL {
    FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-day-rhythm-checks", isDirectory: true)
        .appendingPathComponent("\(name).json")
}

private func localDate(
    year: Int = 2026,
    month: Int = 7,
    day: Int,
    hour: Int,
    minute: Int = 0
) -> Date {
    Calendar.current.date(from: DateComponents(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    ))!
}

private func shiftedDay(_ date: Date, days: Int, hour: Int, minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let shifted = calendar.date(byAdding: .day, value: days, to: date)!
    var components = calendar.dateComponents([.year, .month, .day], from: shifted)
    components.hour = hour
    components.minute = minute
    return calendar.date(from: components)!
}

private func checkMedian7Days(_ check: (String, Bool) -> Void) async {
    let rhythm = AtlasDayRhythm(storeURL: makeRhythmURL())
    let now = localDate(day: 16, hour: 12)
    for offset in -7...0 {
        let startHour = offset == -7 ? 2 : 14 + offset // recent 7 => 8...14
        let endHour = offset == -7 ? 23 : 23 + offset // recent 7 => 17...23
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: startHour))
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: endHour))
    }
    let windows = await rhythm.windows(now: now)
    check(
        "rhythm_median_7days",
        windows.sampleDays == 8
            && windows.dayStart?.hour == 11
            && windows.dayStart?.minute == 0
            && windows.dayEnd?.hour == 20
            && windows.dayEnd?.minute == 0
    )
}

private func checkColdStartNil(_ check: (String, Bool) -> Void) async {
    let rhythm = AtlasDayRhythm(storeURL: makeRhythmURL())
    let now = localDate(day: 16, hour: 12)
    for offset in -2...0 {
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: 9))
    }
    let windows = await rhythm.windows(minimumDays: 4, now: now)
    check(
        "rhythm_cold_start_nil",
        windows.sampleDays == 3 && windows.dayStart == nil && windows.dayEnd == nil
    )
}

private func checkIgnoresEmptyDays(_ check: (String, Bool) -> Void) async {
    let file = makeRhythmURL()
    try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
    let payload = Data("""
    {"v":1,"days":[
      {"date":"2026-07-12","workspaces":["fantasma"]},
      {"date":"2026-07-13","first":"08:00","last":"20:00","workspaces":[]},
      {"date":"2026-07-14","first":"09:00","last":"21:00","workspaces":[]},
      {"date":"2026-07-15","first":"10:00","last":"22:00","workspaces":[]},
      {"date":"2026-07-16","first":"11:00","last":"23:00","workspaces":[]}
    ]}
    """.utf8)
    try? payload.write(to: file, options: .atomic)

    let windows = await AtlasDayRhythm(storeURL: file).windows(now: localDate(day: 16, hour: 12))
    check(
        "rhythm_ignores_empty_days",
        windows.sampleDays == 4
            && windows.dayStart?.hour == 9
            && windows.dayStart?.minute == 30
            && windows.dayEnd?.hour == 21
            && windows.dayEnd?.minute == 30
    )
}

private func checkTodayWorkspacesDedup(_ check: (String, Bool) -> Void) async {
    let rhythm = AtlasDayRhythm(storeURL: makeRhythmURL())
    let now = localDate(day: 16, hour: 9)
    await rhythm.recordActivity(workspace: "/Users/v/Atlas/atlas-native", now: now)
    await rhythm.recordActivity(workspace: "atlas-native", now: localDate(day: 16, hour: 10))
    await rhythm.recordActivity(workspace: "atlas-server", now: localDate(day: 16, hour: 11))
    await rhythm.recordActivity(workspace: nil, now: localDate(day: 16, hour: 12))

    let summary = await rhythm.todaySummary(now: now)
    check("rhythm_today_workspaces_dedup", summary.workspaces == ["atlas-native", "atlas-server"])
}

private func checkPersistenceRoundtrip(_ check: (String, Bool) -> Void) async {
    let file = makeRhythmURL()
    let now = localDate(day: 16, hour: 12)
    let first = AtlasDayRhythm(storeURL: file)
    await first.recordActivity(workspace: "atlas-native", now: localDate(day: 16, hour: 8, minute: 12))
    await first.recordActivity(workspace: "atlas-native", now: localDate(day: 16, hour: 21, minute: 3))

    let relaunched = AtlasDayRhythm(storeURL: file)
    let summary = await relaunched.todaySummary(now: now)
    let windows = await relaunched.windows(minimumDays: 1, now: now)
    check(
        "rhythm_persistence_roundtrip",
        summary.workspaces == ["atlas-native"]
            && windows.dayStart?.hour == 8
            && windows.dayStart?.minute == 12
            && windows.dayEnd?.hour == 21
            && windows.dayEnd?.minute == 3
    )
}

private func checkFutureVersionLoadKeepsKnownFields(_ check: (String, Bool) -> Void) async {
    let file = makeRhythmURL()
    try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
    let payload = Data("""
    {"v":2,"extra":"ignored","days":[
      {"date":"2026-07-13","first":"08:00","last":"20:00","workspaces":["atlas-native"],"new_field":true},
      {"date":"2026-07-14","first":"09:00","last":"21:00","workspaces":["atlas-server"]},
      {"date":"2026-07-15","first":"10:00","last":"22:00","workspaces":[]},
      {"date":"2026-07-16","first":"11:00","last":"23:00","workspaces":[]}
    ]}
    """.utf8)
    try? payload.write(to: file, options: .atomic)

    let rhythm = AtlasDayRhythm(storeURL: file)
    let summary = await rhythm.todaySummary(now: localDate(day: 13, hour: 12))
    let windows = await rhythm.windows(now: localDate(day: 16, hour: 12))
    check(
        "rhythm_future_version_tolerant_load",
        summary.workspaces == ["atlas-native"]
            && windows.sampleDays == 4
            && windows.dayStart?.hour == 9
            && windows.dayStart?.minute == 30
    )
}

private func checkCap14Days(_ check: (String, Bool) -> Void) async {
    let file = makeRhythmURL()
    let rhythm = AtlasDayRhythm(storeURL: file)
    let now = localDate(day: 20, hour: 12)
    for offset in -19...0 {
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: 9))
    }
    let data = (try? Data(contentsOf: file)) ?? Data()
    let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    let days = object?["days"] as? [[String: Any]]
    check("rhythm_cap_14_days", days?.count == 14 && days?.first?["date"] as? String == "2026-07-07")
}

private func checkTimezoneChangeSafe(_ check: (String, Bool) -> Void) async {
    let file = makeRhythmURL()
    let rhythm = AtlasDayRhythm(storeURL: file)
    let now = localDate(day: 16, hour: 12)
    for offset in -3...0 {
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: 8 + abs(offset)))
    }
    let windows = await rhythm.windows(now: shiftedDay(now, days: 0, hour: 23, minute: 59))
    check("rhythm_timezone_change_safe", windows.sampleDays == 4 && windows.dayStart != nil && windows.dayEnd != nil)
}

private func checkWindowsMinutesToComponents(_ check: (String, Bool) -> Void) async {
    let rhythm = AtlasDayRhythm(storeURL: makeRhythmURL())
    let now = localDate(day: 16, hour: 12)
    let starts = [(0, 0), (1, 0), (2, 0), (3, 0)]
    let ends = [(20, 0), (21, 0), (22, 0), (23, 0)]
    for offset in -3...0 {
        let index = offset + 3
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: starts[index].0, minute: starts[index].1))
        await rhythm.recordActivity(workspace: nil, now: shiftedDay(now, days: offset, hour: ends[index].0, minute: ends[index].1))
    }
    let windows = await rhythm.windows(now: now)
    check(
        "rhythm_windows_minutes_to_components",
        windows.dayStart?.hour == 1
            && windows.dayStart?.minute == 30
            && windows.dayEnd?.hour == 21
            && windows.dayEnd?.minute == 30
    )
}
