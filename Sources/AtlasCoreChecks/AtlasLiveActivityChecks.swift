import Foundation
import AtlasCore

public func runAtlasLiveActivityChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas Live Activity · contrato de token remoto:")

    let input = AtlasLiveActivityRegistrationInput(
        traceId: "trace-1",
        activityId: "activity-1",
        installationId: "install-1",
        pushToken: "abcd",
        environment: .sandbox,
        startedAt: Date(timeIntervalSince1970: 1_784_185_600),
        frequentUpdatesEnabled: true
    )
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let object = (try? encoder.encode(input)).flatMap {
        try? JSONSerialization.jsonObject(with: $0) as? [String: Any]
    }
    check("registro usa o trace e a atividade reais", object?["trace_id"] as? String == "trace-1" && object?["activity_id"] as? String == "activity-1" && object?["installation_id"] as? String == "install-1")
    check("token é exclusivo e frequencia é declarada", object?["push_token"] as? String == "abcd" && object?["frequent_updates_enabled"] as? Bool == true)
    check("ambiente APNs é explícito", object?["environment"] as? String == "sandbox")

    let receiptJSON = """
    {"registration":{"id":"reg-1","trace_id":"trace-1","activity_id":"activity-1","status":"active"}}
    """.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let receipt = try? decoder.decode(AtlasLiveActivityRegistrationResponse.self, from: receiptJSON)
    check("receipt nunca devolve o push token", receipt?.registration.registrationId == "reg-1" && receipt?.registration.status == "active")

    let startTokenJSON = """
    {"registration":{"id":"start-1","installation_id":"install-1","status":"active"}}
    """.data(using: .utf8)!
    let startReceipt = try? decoder.decode(AtlasLiveActivityStartTokenResponse.self, from: startTokenJSON)
    check("token de início remoto não devolve segredo", startReceipt?.registration.registrationId == "start-1" && startReceipt?.registration.installationId == "install-1")
}
