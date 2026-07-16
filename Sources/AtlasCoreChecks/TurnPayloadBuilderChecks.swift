import Foundation
import AtlasCore

public func runTurnPayloadBuilderChecks(_ check: (String, Bool) -> Void) {
    let longMessage = JSONObject([
        "schema": .string("atlas.long_message.v1"),
        "original_chars": .number(42001),
        "artifact_name": .string("atlas-long-message.md"),
    ])
    let workspace = TurnPayloadBuilder.Workspace(
        slug: "atlas-native",
        name: "Atlas Native",
        path: "/Users/vitorepf/develop/Atlas/atlas-native"
    )

    let payload = TurnPayloadBuilder.build(
        taskKind: "code",
        effort: .deep,
        workspace: workspace,
        longMessage: longMessage,
        operatorText: "operador escreveu isto"
    )

    let expected = JSONObject([
        "tool_permissions": .object(["mode": .string("read")]),
        "task_type": .string("code"),
        "compute_effort": .string("deep"),
        "long_message": .object(longMessage.values),
        "workspace_slug": .string("atlas-native"),
        "workspace_name": .string("Atlas Native"),
        "workspace_path": .string("/Users/vitorepf/develop/Atlas/atlas-native"),
        "operator_text": .string("operador escreveu isto"),
    ])

    check("turn payload builder reproduz payload manual completo", payload == expected)

    let mobilePayload = atlasMobileInteractionPayload(base: payload)
    check("turn payload continua aceitando política mobile existente",
          mobilePayload["app_surface"]?.stringValue == "atlas_app" &&
          mobilePayload["mobile_surface_id"]?.stringValue == "atlas_native_conversation" &&
          mobilePayload["hermes"]?["execution_transport"]?.stringValue == "acp" &&
          mobilePayload["tool_permissions"]?["mode"]?.stringValue == "read")

    let minimal = TurnPayloadBuilder.build(
        taskKind: nil,
        effort: .auto,
        workspace: nil,
        longMessage: nil,
        operatorText: nil
    )
    check("turn payload mínimo só declara permissão read",
          minimal == JSONObject(["tool_permissions": .object(["mode": .string("read")])]))
}
