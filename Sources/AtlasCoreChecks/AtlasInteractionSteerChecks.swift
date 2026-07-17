import Foundation
import AtlasCore

public func runAtlasInteractionSteerChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas AI · M07 steer interaction:")
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    check(
        "rota steer usa trace codificado",
        AtlasRoute.aiInteractionSteer("trace/7") == "/ai/interactions/trace%2F7/steer"
    )

    let acceptedJSON = """
    {"schema_version":"atlas.ai.interaction_steer.v1","status":"accepted",
     "event":"steering_accepted","trace_id":"trace_7",
     "delivery":{"status":"queued_for_next_safe_checkpoint"}}
    """
    let accepted = try? decoder.decode(
        AtlasInteractionSteerResponse.self,
        from: Data(acceptedJSON.utf8)
    )
    check(
        "steer aceito falha fechado no schema e preserva delivery seguro",
        accepted?.schemaVersion == AtlasInteractionSteerResponse.schemaVersion
            && accepted?.status == .accepted
            && accepted?.event == .accepted
            && accepted?.delivery?.status == .queuedForNextSafeCheckpoint
    )

    let rejectedJSON = """
    {"schema_version":"atlas.ai.interaction_steer.v1","status":"rejected",
     "event":"steering_rejected","trace_id":"trace_7",
     "reason":"invalid_scope","delivery":{"status":"not_queued"}}
    """
    let rejected = try? decoder.decode(
        AtlasInteractionSteerResponse.self,
        from: Data(rejectedJSON.utf8)
    )
    check(
        "steer rejeitado preserva motivo fechado",
        rejected?.status == .rejected
            && rejected?.event == .rejected
            && rejected?.reason == .invalidScope
    )

    let badSchema = acceptedJSON.replacingOccurrences(
        of: "atlas.ai.interaction_steer.v1",
        with: "atlas.ai.interaction_steer.v0"
    )
    check(
        "steer rejeita schema desconhecido",
        (try? decoder.decode(AtlasInteractionSteerResponse.self, from: Data(badSchema.utf8))) == nil
    )

    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let input = AtlasInteractionSteerInput(
        instruction: "priorize a verificação",
        scope: .replan
    )
    let payload = (try? JSONSerialization.jsonObject(with: encoder.encode(input))) as? [String: Any]
    check(
        "steer input codifica instruction + scope em snake_case",
        payload?["instruction"] as? String == "priorize a verificação"
            && payload?["scope"] as? String == "replan"
    )
}
