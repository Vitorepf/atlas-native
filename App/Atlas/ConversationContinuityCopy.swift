import Foundation

// Continuity copy (presentation-only) — peel de ConversationChromeSheets.
// Age → ConversationContinuityCopy+Age.swift

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
