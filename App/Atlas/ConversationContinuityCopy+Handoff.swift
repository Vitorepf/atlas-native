import Foundation

// Handoff status editorial — peel de ConversationContinuityCopy.

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}
