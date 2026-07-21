import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive change-review control face (WAVE-175) — assinatura run + file.
enum ChangeReviewControlFace: Equatable {
    /// Review missing / no control surface.
    case empty
    /// Surface exists but no accept/reject published.
    case silent
    /// Run-level availableActions non-empty.
    case runActions(accept: Bool, reject: Bool)
    /// No run actions; files still undecided (file CTAs only).
    case fileUndecided(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .silent: return "silent"
        case .runActions: return "run_actions"
        case .fileUndecided: return "file_undecided"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "revisão sem controle publicado"
        case .silent:
            return "revisão sem ações aceitar ou rejeitar publicadas"
        case .runActions(let accept, let reject):
            var parts: [String] = ["ações de assinatura publicadas"]
            if accept { parts.append("aceitar") }
            if reject { parts.append("rejeitar") }
            return parts.joined(separator: ", ")
        case .fileUndecided(let n):
            return n == 1
                ? "1 arquivo ainda sem decisão no patch"
                : "\(n) arquivos ainda sem decisão no patch"
        }
    }
}

// MARK: - Judgment

/// Pure change-review control grammar — face · pack · CTA labels.
/// Never invents availableActions. NL never applies review (face CTA only).
enum ChangeReviewControlJudgment {

    // MARK: Labels (one law file + run)

    static let acceptRunLabel = "Aceitar tudo"
    static let rejectRunLabel = "Rejeitar"
    static let acceptFileLabel = "aceitar"
    static let rejectFileLabel = "rejeitar"
    static let nlNeverAppliesAbsence =
        "NL de chat não aplica revisão — só CTAs do sheet (faceCTALocal)"

    // MARK: Counts

    static func availableActions(from review: AtlasTraceChangeReview?) -> [AtlasTraceChangeReview.Action] {
        review?.review.availableActions ?? []
    }

    /// Files listed on patches without a matching fileReview decision.
    static func undecidedFileCount(from review: AtlasTraceChangeReview) -> Int {
        var count = 0
        for patch in review.patches {
            let decided = Set(patch.fileReviews.map(\.filePath))
            var paths = Set(patch.changedFiles)
            paths.formUnion(patch.createdFiles)
            paths.formUnion(patch.deletedFiles)
            for path in paths where !decided.contains(path) {
                count += 1
            }
        }
        return count
    }

    static func decidedFileCount(from review: AtlasTraceChangeReview) -> Int {
        review.patches.reduce(0) { $0 + $1.fileReviews.count }
    }

    static func hasPublishedControlActions(from review: AtlasTraceChangeReview?) -> Bool {
        guard let review else { return false }
        if !review.review.availableActions.isEmpty { return true }
        return undecidedFileCount(from: review) > 0
    }

    // MARK: Face

    static func face(from review: AtlasTraceChangeReview?) -> ChangeReviewControlFace {
        guard let review else { return .empty }
        let actions = review.review.availableActions
        if !actions.isEmpty {
            return .runActions(
                accept: actions.contains(.accept),
                reject: actions.contains(.reject)
            )
        }
        let undecided = undecidedFileCount(from: review)
        if undecided > 0 { return .fileUndecided(undecided) }
        if ChangeReviewJudgment.hasReviewSurface(review) {
            return .silent
        }
        return .empty
    }

    // MARK: Pack

    static func packFacts(
        from review: AtlasTraceChangeReview?,
        applying: Bool? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: review)
        facts.append("review_control_face: \(face.productWord)")

        guard let review else {
            absences.append("revisão de mudanças não hidratada — sem availableActions")
            absences.append(nlNeverAppliesAbsence)
            return (facts, absences)
        }

        let actions = review.review.availableActions
        if actions.isEmpty {
            absences.append("sem ações de assinatura publicadas (availableActions vazio)")
        } else {
            facts.append("review_available_actions: \(actions.map(\.rawValue).joined(separator: "|"))")
            for action in actions {
                facts.append("review_action: \(action.rawValue)")
            }
            if actions.contains(.accept) {
                facts.append("review_cta_run_accept: \(acceptRunLabel)")
            }
            if actions.contains(.reject) {
                facts.append("review_cta_run_reject: \(rejectRunLabel)")
            }
        }

        let undecided = undecidedFileCount(from: review)
        let decided = decidedFileCount(from: review)
        if undecided > 0 {
            facts.append("review_files_undecided: \(undecided)")
            facts.append("review_cta_file_accept: \(acceptFileLabel)")
            facts.append("review_cta_file_reject: \(rejectFileLabel)")
        } else if !review.patches.isEmpty {
            absences.append("nenhum arquivo pendente de decisão no patch")
        }
        if decided > 0 {
            facts.append("review_files_decided: \(decided)")
        }

        if !review.review.operatorActions.isEmpty {
            facts.append("review_operator_actions: \(review.review.operatorActions.count)")
        }

        if let applying {
            facts.append("review_applying: \(applying ? "yes" : "no")")
        } else {
            absences.append("applying é estado local do sheet — pack não inventa")
        }

        absences.append(nlNeverAppliesAbsence)
        return (facts, absences)
    }

    /// Spoken run CTA labels — one law with face buttons.
    static func spokenRunAccept() -> String { acceptRunLabel.lowercased() }
    static func spokenRunReject() -> String { rejectRunLabel.lowercased() }
}
