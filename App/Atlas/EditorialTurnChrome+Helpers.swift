import SwiftUI

// Helpers duração/provider — peel de EditorialTurnChrome+Feedback.

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

/// claude_cli → "claude", conselho → "conselho", etc. Vazio ≠ fabricar «atlas».
func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}
