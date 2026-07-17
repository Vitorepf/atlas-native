import Foundation

// MARK: - Classificação de kind (porte de attachmentKind.ts + types.ts)

public enum AtlasAttachmentClassifier {
    public static let supportedImageMime: Set<String> =
        ["image/png", "image/jpeg", "image/jpg", "image/webp", "image/gif"]
    public static let supportedPdfMime: Set<String> = ["application/pdf"]
    public static let supportedTextMimePrefixes = ["text/", "application/json", "application/xml"]

    public static let codeLangByExt: [String: String] = [
        "ts": "typescript", "tsx": "tsx", "js": "javascript", "jsx": "jsx",
        "mjs": "javascript", "cjs": "javascript", "py": "python", "rb": "ruby",
        "rs": "rust", "go": "go", "java": "java", "c": "c", "cpp": "cpp",
        "cc": "cpp", "cxx": "cpp", "hpp": "cpp", "h": "c", "cs": "csharp",
        "php": "php", "swift": "swift", "kt": "kotlin", "scala": "scala",
        "sh": "bash", "bash": "bash", "zsh": "bash", "fish": "bash", "sql": "sql",
        "html": "html", "htm": "html", "xml": "xml", "css": "css", "scss": "css",
        "less": "css", "md": "markdown", "yml": "yaml", "yaml": "yaml",
        "toml": "toml", "json": "json", "jsonc": "json", "vue": "vue",
        "svelte": "svelte", "dart": "dart", "lua": "lua", "ex": "elixir",
        "exs": "elixir", "erl": "erlang", "elm": "elm", "hs": "haskell",
        "ml": "ocaml", "zig": "zig", "diff": "diff", "patch": "diff",
        "conf": "ini", "ini": "ini", "env": "bash", "dockerfile": "docker",
    ]

    public static func detectLanguage(fromFilename name: String) -> String? {
        let lower = name.lowercased()
        if lower == "dockerfile" || lower.hasSuffix("/dockerfile") { return "docker" }
        if lower == "makefile" { return "makefile" }
        let ext = lower.split(separator: ".").last.map(String.init) ?? ""
        return codeLangByExt[ext]
    }

    public static func detect(mimeType: String, fileName: String) -> AtlasDetectedKind {
        let mime = mimeType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let name = fileName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if supportedImageMime.contains(mime) {
            return .init(kind: .image, language: nil, reason: "mime:\(mime)")
        }
        if supportedPdfMime.contains(mime) {
            return .init(kind: .pdf, language: nil, reason: "mime:\(mime)")
        }
        let language = detectLanguage(fromFilename: name)
        if let language, language != "markdown" {
            return .init(kind: .code, language: language, reason: "ext:\(language)")
        }
        let matchesTextPrefix = supportedTextMimePrefixes.contains { mime.hasPrefix($0) }
        if language == "markdown" {
            return .init(kind: .text, language: "markdown", reason: "ext:markdown")
        }
        if matchesTextPrefix {
            return .init(kind: .text, language: nil, reason: "mime:\(mime)")
        }
        return .init(kind: .text, language: nil, reason: "fallback:\(mime.isEmpty ? "unknown" : mime)")
    }
}
