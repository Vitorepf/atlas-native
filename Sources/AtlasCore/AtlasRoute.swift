import Foundation

public enum AtlasRoute {
    public static let aiThreads = "/ai/threads"
    public static let aiInteractions = "/ai/interactions"
    public static let aiJobs = "/ai/jobs"
    public static let codeGraph = "/code/graph"
    public static let codeViolations = "/code/violations"
    public static let codeRepos = "/code/repos"
    public static let codeAsk = "/code/ask"
    public static let codeMirror = "/code/mirror"
    public static let codeHealsTick = "/code/heals/tick"
    public static let codeWeek = "/code/week"
    public static let codeWhy = "/code/why"
    public static let liveActivities = "/ai/live-activities"
    public static let liveActivityStartTokens = "/ai/live-activities/start-tokens"
    public static let uploadChunksStart = "/ai/uploads/chunks/start"
    public static let arenaComposite = "/arena/composite"
    public static let arenaScoreboard = "/arena/scoreboard"
    public static let arenaReport = "/arena/report"
    public static let arenaLiveRuns = "/arena/runs/live"
    public static let arenaEngines = "/arena/engines"
    public static let arenaRuns = "/arena/runs"
    public static let autonomosAreas = "/ai/software-company-stewardship/loop/areas"
    public static let autonomosDigest = "/ai/software-company-stewardship/autonomos/digest"
    public static let agentsStatus = "/agents/status"
    public static let agentsHistory = "/agents/history"
    public static let agentsTaskHealth = "/agents/task-health"

    static let arenaCapabilitiesBase = "/arena/capabilities"
    static let aiSessionsLiveBase = "/ai/sessions/live"

    static func component(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? value
    }
}

public func runAtlasRouteChecks(_ check: (String, Bool) -> Void) {
    check("route threads collection", AtlasRoute.aiThreads == "/ai/threads")
    check("route path component encodes slash and space",
          AtlasRoute.aiThread("th/a b") == "/ai/threads/th%2Fa%20b")
    check("route stream preserves timeout/after query",
          AtlasRoute.aiInteractionStream("trace/1", timeout: 120, after: 9) == "/ai/interactions/trace%2F1/stream?timeout=120&after=9")
    check("route steer encodes trace id",
          AtlasRoute.aiInteractionSteer("trace/1") == "/ai/interactions/trace%2F1/steer")
    check("route change review diff encodes both ids",
          AtlasRoute.aiInteractionChangeReviewDiff(traceId: "tr 1", patchId: "patch/2") == "/ai/interactions/tr%201/change-review/patches/patch%2F2/diff")
    check("route live sessions encodes installation",
          AtlasRoute.aiSessionsLive(installation: "install/1 234567890") == "/ai/sessions/live?installation=install%2F1%20234567890")
    check("route artifact content encodes ids and max bytes",
          AtlasRoute.aiInteractionArtifactContent(traceId: "tr/1", artifactId: "art 2", maxBytes: 9) == "/ai/interactions/tr%2F1/artifacts/art%202/content?max_bytes=9")
    check("route Arena capabilities encodes engine",
          AtlasRoute.arenaCapabilities(engine: "codex/cli") == "/arena/capabilities?engine=codex%2Fcli")
    check("route upload chunk uses canonical chunks path",
          AtlasRoute.uploadChunk("up/7") == "/ai/uploads/chunks/up%2F7/chunk")
    check("route autonomos transfer status keeps area and handoff encoded",
          AtlasRoute.autonomosTransferStatus(area: "obra/17", handoffId: "handoff 9") == "/ai/software-company-stewardship/loop/obra%2F17/transfer/handoff%209")
    check("route code why uses canonical H1 path", AtlasRoute.codeWhy == "/code/why")
}
