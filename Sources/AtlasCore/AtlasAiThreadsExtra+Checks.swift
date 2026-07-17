import Foundation

// MARK: - Golden checks

/// Prova o recibo de surface-handoff (snake→camel + encode do destino fechado).
public func runThreadsExtraChecks(_ check: (String, Bool) -> Void) {
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding

    let surfaceHandoffJSON = """
    {
      "handoff": {
        "schema_version": "atlas.ai.surface_handoff.v1",
        "handoff_id": "surface_1",
        "thread_id": "th_42",
        "session_id": "session_7",
        "from_surface": "atlas_mobile",
        "to_surface": "atlas_terminal",
        "status": "ready",
        "created_at": "2026-07-14T00:00:00Z"
      }
    }
    """
    if let receipt = try? dec.decode(AiSurfaceHandoffResponse.self, from: Data(surfaceHandoffJSON.utf8)) {
        check("surface handoff preserva thread e sessão canônicas", receipt.handoff.threadId == "th_42" && receipt.handoff.sessionId == "session_7")
        check("surface handoff só projeta superfícies e status público", receipt.handoff.fromSurface == "atlas_mobile" && receipt.handoff.toSurface == "atlas_terminal" && receipt.handoff.status == "ready")
    } else {
        check("surface handoff decodes", false)
    }

    let handoffEncoder = JSONEncoder()
    handoffEncoder.keyEncodingStrategy = .convertToSnakeCase
    if let data = try? handoffEncoder.encode(HandoffAiThreadSurfaceInput(toSurface: .terminal)),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
        check("surface handoff só codifica o destino permitido", json == ["to_surface": "atlas_terminal"])
    } else {
        check("surface handoff input encodes", false)
    }
}
