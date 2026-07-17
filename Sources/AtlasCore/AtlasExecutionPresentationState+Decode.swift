import Foundation

extension AtlasExecutionPresentationState {
    static func action(_ value: JSONValue) -> Action? {
        guard case .object(let object) = value,
              let id = text(object["id"], limit: 120),
              let title = text(object["title"], limit: 120),
              let styleValue = object["style"]?.stringValue,
              let style = ActionStyle(rawValue: styleValue)
        else { return nil }
        return Action(id: id, title: title, style: style)
    }

    static func text(_ value: JSONValue?, limit: Int) -> String? {
        guard let raw = value?.stringValue else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= limit else { return nil }
        return trimmed
    }

    static func timestamp(_ value: JSONValue?) -> String? {
        guard let value = text(value, limit: 80), AtlasTime.date(value) != nil else { return nil }
        return value
    }

    static func timer(_ value: JSONValue) -> Timer? {
        guard case .object(let object) = value,
              let rawElapsed = object["elapsed_active_ms"]?.doubleValue,
              rawElapsed.isFinite,
              rawElapsed >= 0,
              rawElapsed.rounded() == rawElapsed,
              rawElapsed <= Double(Int.max),
              let timingValue = object["timing"]?.stringValue,
              let timing = Timer.Timing(rawValue: timingValue)
        else { return nil }

        let runningSince = timestampDate(object["running_since"])
        let pausedAt = timestampDate(object["paused_at"])
        let finishedAt = timestampDate(object["finished_at"])

        switch timing {
        case .running:
            guard runningSince != nil, pausedAt == nil, finishedAt == nil else { return nil }
        case .paused:
            guard pausedAt != nil, runningSince == nil, finishedAt == nil else { return nil }
        case .finished:
            guard finishedAt != nil, runningSince == nil, pausedAt == nil else { return nil }
        }

        return Timer(
            elapsedActiveMilliseconds: Int(rawElapsed),
            timing: timing,
            runningSince: runningSince,
            pausedAt: pausedAt,
            finishedAt: finishedAt
        )
    }

    static func isTimerCompatible(_ timer: Timer, with kind: Kind) -> Bool {
        switch kind {
        case .attentionRequired, .awaitingExternal:
            timer.timing == .paused
        case .replanning, .recovering:
            timer.timing == .running
        case .failed, .completed:
            timer.timing == .finished
        }
    }

    static func timestampDate(_ value: JSONValue?) -> Date? {
        guard let value = timestamp(value) else { return nil }
        return AtlasTime.date(value)
    }
}
