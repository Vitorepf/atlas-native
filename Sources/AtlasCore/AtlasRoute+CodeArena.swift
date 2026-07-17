import Foundation

extension AtlasRoute {
    public static func codeProvenance(_ hash: String) -> String {
        "/code/provenance/\(component(hash))"
    }

    public static func codeHealUndo(_ id: String) -> String {
        "/code/heals/\(component(id))/undo"
    }

    public static func arenaCapabilities(engine: String) -> String {
        "\(arenaCapabilitiesBase)\(atlasQueryString([("engine", .string(engine))]))"
    }
}
