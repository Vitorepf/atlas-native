import Foundation

public enum TurnPayloadBuilder {
    public struct Workspace: Sendable, Equatable {
        public let slug: String
        public let name: String?
        public let path: String?

        public init(slug: String, name: String? = nil, path: String? = nil) {
            self.slug = slug
            self.name = name
            self.path = path
        }
    }

    public static func build(
        taskKind: String?,
        effort: AtlasComputeEffort,
        workspace: Workspace?,
        longMessage: JSONObject?,
        operatorText: String?
    ) -> JSONObject {
        var payload: [String: JSONValue] = [
            "tool_permissions": .object(["mode": .string("read")]),
        ]

        if let taskKind {
            payload["task_type"] = .string(taskKind)
        }
        if let effort = effort.payloadValue {
            payload["compute_effort"] = .string(effort)
        }
        if let longMessage {
            payload["long_message"] = .object(longMessage.values)
        }
        if let workspace {
            payload["workspace_slug"] = .string(workspace.slug)
            payload["workspace_name"] = .string(workspace.name ?? workspace.slug)
            if let path = workspace.path {
                payload["workspace_path"] = .string(path)
            }
        }
        if let operatorText {
            payload["operator_text"] = .string(operatorText)
        }

        return JSONObject(payload)
    }
}
