import Foundation

// Relative age PT — peel de ConversationContinuityCopy.

func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}
