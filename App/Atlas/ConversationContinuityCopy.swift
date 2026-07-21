import Foundation

// Continuity copy (presentation-only) — IDLE-COMPRESS.

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}

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
