import Foundation
import AtlasCore

public func runAtlasCodeWhyChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlas Código · biografia do arquivo (H1):")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let full = """
    {"schema_version":"atlas.code.why.v1","repo":"atlas-native","file":"App/Atlas/RootView.swift",
     "commits_total":34,"truncated":true,
     "commits":[
       {"hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","when":"2026-07-16T22:14:03Z",
        "agent":"fable","subject":"polish(ui): a home respira",
        "provenance":{"quote":"quero a home viva, não um menu","obra":"obra-17","gates":["checks","build"]}},
       {"hash":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","when":"2026-07-15T20:00:00Z",
        "agent":"voce","subject":"feat(core): grafo real","provenance":null}
     ]}
    """

    let why = try? decoder.decode(AtlasCodeWhy.self, from: Data(full.utf8))
    check("why_decode_full",
          why?.schemaVersion == AtlasCodeWhy.schemaVersion &&
          why?.repo == "atlas-native" &&
          why?.file == "App/Atlas/RootView.swift" &&
          why?.commitsTotal == 34 &&
          why?.commits.first?.provenance?.quote == "quero a home viva, não um menu" &&
          why?.commits.first?.provenance?.gates == ["checks", "build"] &&
          why?.commits.first?.when != nil &&
          why?.commits.first?.shortHash == "aaaaaaa")

    let unknownSchema = full.replacingOccurrences(of: "atlas.code.why.v1", with: "atlas.code.why.v2")
    check("why_schema_unknown_fails_closed",
          (try? decoder.decode(AtlasCodeWhy.self, from: Data(unknownSchema.utf8))) == nil)

    check("why_provenance_null_preserved",
          why?.commits.count == 2 && why?.commits[1].provenance == nil && why?.commits[1].agentLabel == "você")

    check("why_truncated_flag", why?.truncated == true && why?.commitsTotal == 34 && why?.commits.count == 2)

    let empty = """
    {"schema_version":"atlas.code.why.v1","repo":"atlas-native","file":"Sources/NeverExisted.swift",
     "commits_total":0,"truncated":false,"commits":[]}
    """
    let emptyDecoded = try? decoder.decode(AtlasCodeWhy.self, from: Data(empty.utf8))
    check("why_empty_commits_ok",
          emptyDecoded?.commits.isEmpty == true &&
          emptyDecoded?.commitsTotal == 0 &&
          emptyDecoded?.truncated == false)
}
