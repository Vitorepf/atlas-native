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
    public static let liveActivities = "/ai/live-activities"
    public static let liveActivityStartTokens = "/ai/live-activities/start-tokens"
    public static let uploadChunksStart = "/ai/uploads/chunks/start"
    public static let autonomosAreas = "/ai/software-company-stewardship/loop/areas"
    public static let agentsStatus = "/agents/status"
    public static let agentsHistory = "/agents/history"
    public static let agentsTaskHealth = "/agents/task-health"

    public static func aiThread(_ id: String) -> String {
        "\(aiThreads)/\(component(id))"
    }

    public static func aiThreadHandoffSurface(_ id: String) -> String {
        "\(aiThread(id))/handoff-surface"
    }

    public static func aiInteraction(_ id: String) -> String {
        "\(aiInteractions)/\(component(id))"
    }

    public static func aiInteractionStream(_ id: String, timeout: Int, after: Int) -> String {
        "\(aiInteraction(id))/stream?timeout=\(timeout)&after=\(after)"
    }

    public static func aiInteractionFeedback(_ id: String) -> String {
        "\(aiInteraction(id))/feedback"
    }

    public static func aiInteractionChangeReview(_ traceId: String) -> String {
        "\(aiInteraction(traceId))/change-review"
    }

    public static func aiInteractionChangeReviewDiff(traceId: String, patchId: String) -> String {
        "\(aiInteractionChangeReview(traceId))/patches/\(component(patchId))/diff"
    }

    public static func aiInteractionChangeReviewAction(_ traceId: String) -> String {
        "\(aiInteractionChangeReview(traceId))/action"
    }

    public static func aiInteractionChangeReviewFileAction(_ traceId: String) -> String {
        "\(aiInteractionChangeReview(traceId))/file-action"
    }

    public static func aiInteractionArtifacts(_ traceId: String) -> String {
        "\(aiInteraction(traceId))/artifacts"
    }

    public static func aiInteractionArtifactContent(traceId: String, artifactId: String, maxBytes: Int) -> String {
        let capped = min(max(maxBytes, 1), 10_485_760)
        return "\(aiInteractionArtifacts(traceId))/\(component(artifactId))/content?max_bytes=\(capped)"
    }

    public static func codeProvenance(_ hash: String) -> String {
        "/code/provenance/\(component(hash))"
    }

    public static func codeHealUndo(_ id: String) -> String {
        "/code/heals/\(component(id))/undo"
    }

    public static func liveActivityInvalidate(_ activityId: String) -> String {
        "\(liveActivities)/\(component(activityId))/invalidate"
    }

    public static func uploadChunk(_ uploadId: String) -> String {
        "/ai/uploads/chunks/\(component(uploadId))/chunk"
    }

    public static func uploadChunksComplete(_ uploadId: String) -> String {
        "/ai/uploads/chunks/\(component(uploadId))/complete"
    }

    public static func aiJob(_ id: String) -> String {
        "\(aiJobs)/\(component(id))"
    }

    public static func aiJobRetry(_ id: String) -> String {
        "\(aiJob(id))/retry"
    }

    public static func aiJobCancel(_ id: String) -> String {
        "\(aiJob(id))/cancel"
    }

    public static func aiJobResumeChoice(_ id: String) -> String {
        "\(aiJob(id))/resume-choice"
    }

    public static func autonomosLive(area: String) -> String {
        "\(autonomosLoop(area: area))/live"
    }

    public static func autonomosCycles(area: String) -> String {
        "\(autonomosLoop(area: area))/cycles"
    }

    public static func autonomosDone(area: String) -> String {
        "\(autonomosLoop(area: area))/done"
    }

    public static func autonomosBacklog(area: String) -> String {
        "\(autonomosLoop(area: area))/backlog"
    }

    public static func autonomosRunControl(area: String) -> String {
        "\(autonomosLoop(area: area))/run-control"
    }

    public static func autonomosStartRun(area: String) -> String {
        "\(autonomosLoop(area: area))/start-run"
    }

    public static func autonomosTransfer(area: String) -> String {
        "\(autonomosLoop(area: area))/transfer"
    }

    public static func autonomosTransferStatus(area: String, handoffId: String) -> String {
        "\(autonomosTransfer(area: area))/\(component(handoffId))"
    }

    public static func autonomosOperatorDecision(area: String) -> String {
        "\(autonomosLoop(area: area))/operator-decision"
    }

    private static func autonomosLoop(area: String) -> String {
        "/ai/software-company-stewardship/loop/\(component(area))"
    }

    private static func component(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? value
    }
}

public func runAtlasRouteChecks(_ check: (String, Bool) -> Void) {
    check("route threads collection", AtlasRoute.aiThreads == "/ai/threads")
    check("route path component encodes slash and space",
          AtlasRoute.aiThread("th/a b") == "/ai/threads/th%2Fa%20b")
    check("route stream preserves timeout/after query",
          AtlasRoute.aiInteractionStream("trace/1", timeout: 120, after: 9) == "/ai/interactions/trace%2F1/stream?timeout=120&after=9")
    check("route change review diff encodes both ids",
          AtlasRoute.aiInteractionChangeReviewDiff(traceId: "tr 1", patchId: "patch/2") == "/ai/interactions/tr%201/change-review/patches/patch%2F2/diff")
    check("route artifact content encodes ids and max bytes",
          AtlasRoute.aiInteractionArtifactContent(traceId: "tr/1", artifactId: "art 2", maxBytes: 9) == "/ai/interactions/tr%2F1/artifacts/art%202/content?max_bytes=9")
    check("route upload chunk uses canonical chunks path",
          AtlasRoute.uploadChunk("up/7") == "/ai/uploads/chunks/up%2F7/chunk")
    check("route autonomos transfer status keeps area and handoff encoded",
          AtlasRoute.autonomosTransferStatus(area: "obra/17", handoffId: "handoff 9") == "/ai/software-company-stewardship/loop/obra%2F17/transfer/handoff%209")
}
