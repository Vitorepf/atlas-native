import Foundation

extension AtlasRoute {
    public static func aiThread(_ id: String) -> String {
        "\(aiThreads)/\(component(id))"
    }

    public static func aiSessionsLive(installation: String) -> String {
        "\(aiSessionsLiveBase)\(atlasQueryString([("installation", .string(installation))]))"
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

    public static func aiInteractionSteer(_ id: String) -> String {
        "\(aiInteraction(id))/steer"
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
}
