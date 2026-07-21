import AtlasCore

// Spoken + pass predicates — peel de ArtifactSheet+DeliveryProof.

extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}
