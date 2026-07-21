import Foundation

// Surface label — peel de ConversationContinuityCopy.

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}
