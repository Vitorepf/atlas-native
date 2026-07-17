import AtlasCore

// Provas de montagem — só controles/testes reais do contrato C15 (nunca inventa 0/3).

struct ArtifactDeliveryCheck: Identifiable, Equatable {
    let id: String
    let label: String
    let status: String

    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

enum ArtifactDeliveryProof {
    /// Controles + testRuns publicados na revisão trace-scoped — vazio = silêncio na montagem.
    static func checks(from review: AtlasTraceChangeReview?) -> [ArtifactDeliveryCheck] {
        guard review?.state == .available, let review else { return [] }
        let controls = review.controls.map {
            ArtifactDeliveryCheck(id: "control-\($0.id)", label: $0.slug, status: $0.status)
        }
        let tests = review.testRuns.map {
            ArtifactDeliveryCheck(id: "test-\($0.id)", label: $0.command ?? "teste", status: $0.status)
        }
        return controls + tests
    }
}
