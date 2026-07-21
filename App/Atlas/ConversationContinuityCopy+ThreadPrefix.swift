import Foundation

// Thread id prefix — peel de ConversationContinuityCopy.

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}
