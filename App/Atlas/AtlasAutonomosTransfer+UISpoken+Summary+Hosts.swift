import AtlasCore

// Transfer host spoken — peel de AtlasAutonomosTransfer+UISpoken+Summary.

extension AtlasAutonomosTransferResponse {
    var transferSpokenHostParts: [String] {
        var parts: [String] = []
        if let host = handoff.source.host?.nonEmpty { parts.append("fonte \(host)") }
        if isTargetClaimed, let host = handoff.target.host?.nonEmpty {
            parts.append("alvo \(host)")
        } else if isHandoffInFlight {
            parts.append("alvo ainda desconhecido")
        }
        return parts
    }
}
