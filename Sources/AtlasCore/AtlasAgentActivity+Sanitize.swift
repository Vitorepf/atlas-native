import Foundation

func containsSensitiveCommandMaterial(_ lower: String) -> Bool {
    let sensitiveMarkers = [
        "authorization:", "bearer ", "token=", "token:", "api_key=", "api-key=",
        "apikey=", "secret=", "secret:", "password=", "password:", "private_key=",
        "--token", "--api-key", "--apikey", "--secret", "--password", "--private-key",
    ]
    return sensitiveMarkers.contains(where: lower.contains)
}

func safeCommandText(_ value: String) -> String {
    let singleLine = value.replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
    guard !containsSensitiveCommandMaterial(singleLine.lowercased()) else { return "<redacted>" }
    return String(singleLine.prefix(240))
}

func safeFileSummary(_ value: String) -> String {
    value.split(separator: ",", maxSplits: 4).map { raw in
        let path = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return (path as NSString).lastPathComponent
    }.filter { !$0.isEmpty }.joined(separator: ", ")
}

func pathDetail(_ metadata: JSONObject) -> String? {
    for key in ["path", "file", "file_path", "relative_path"] {
        if let value = metadata[key]?.stringValue, !value.isEmpty {
            return (value as NSString).lastPathComponent
        }
    }
    return nil
}

func safeActivityDetail(_ value: String) -> String {
    let singleLine = value.replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "\r", with: " ")
    return String(singleLine.prefix(240))
}
