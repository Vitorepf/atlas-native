import Foundation
import AtlasCore

public func runAtlasCodeGraphChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "schema_version":"atlas.code.graph.v1",
      "repo":"atlas-server",
      "generated_at":"2026-07-15T05:00:00Z",
      "head":"9a06fd4c56",
      "default_branch":"main",
      "nodes":[{"hash":"9a06fd4c56","parents":["4b2b61f974","7c1e8d2a90"],"refs":["main"],"author_name":"Vitor Freire","author_email":"vitor@example.test","authored_at":1784316000}],
      "worktrees":[{"path":"/Users/vitor/worktrees/atlas","branch":"main","head":"9a06fd4c56"}],
      "pagination":{"limit":200,"before":null,"has_more":false},
      "cache":{"strategy":"refs_fingerprint","refs_fingerprint":"abc","invalidated":false}
    }
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    let decoded = try? decoder.decode(AtlasCodeGraphResponse.self, from: Data(json.utf8))

    check("grafo C22 preserva o hash e os pais reais", decoded?.nodes.first?.hash == "9a06fd4c56" && decoded?.nodes.first?.parents.count == 2)
    check("grafo C22 preserva autor e refs", decoded?.nodes.first?.authorEmail == "vitor@example.test" && decoded?.nodes.first?.refs == ["main"])
    check("grafo C22 preserva worktree sem inventar estado", decoded?.worktrees.first?.branch == "main" && decoded?.worktrees.first?.head == "9a06fd4c56")
    check("grafo C22 preserva paginação/cache", decoded?.pagination.limit == 200 && decoded?.cache.invalidated == false)
    check("curva do grafo usa midpoint com tangentes verticais", AtlasCodeGraphGeometry.midpointPath(fromX: 24, fromY: 10, toX: 56, toY: 50) == "M 24.0,10.0 C 24.0,30.0 56.0,30.0 56.0,50.0")

    let unknownSchema = json.replacingOccurrences(of: "atlas.code.graph.v1", with: "atlas.code.graph.v2")
    check("schema de grafo desconhecido falha fechado", (try? decoder.decode(AtlasCodeGraphResponse.self, from: Data(unknownSchema.utf8))) == nil)
}
