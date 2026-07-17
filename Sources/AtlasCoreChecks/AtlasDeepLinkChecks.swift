import Foundation
import AtlasCore

func runAtlasDeepLinkChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlasDeepLink (widgets → Route, fail-closed):")

    func parse(_ raw: String) -> AtlasDeepLink? {
        guard let url = URL(string: raw) else { return nil }
        return AtlasDeepLink.parse(url)
    }

    check("autonomos", parse("atlas://autonomos") == .autonomos)
    check("autonomos ignora path extra", parse("atlas://autonomos/foo") == .autonomos)
    check("code bare → radar", parse("atlas://code") == .codeHome)
    check("code bare com slash", parse("atlas://code/") == .codeHome)
    check("code/repo", parse("atlas://code/atlas-native") == .code(repo: "atlas-native"))
    check("execution bare", parse("atlas://execution") == .executionHome)
    check("execution bare com slash", parse("atlas://execution/") == .executionHome)
    check("execution/trace", parse("atlas://execution/tr_abc") == .execution(traceId: "tr_abc"))
    check("https → nil", parse("https://atlas/execution") == nil)
    check("host desconhecido → nil", parse("atlas://rivals") == nil)
    check("scheme ausente → nil", parse("autonomos") == nil)
}
