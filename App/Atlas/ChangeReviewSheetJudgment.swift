import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive change-review sheet load face (WAVE-063).
enum ChangeReviewSheetFace: Equatable {
    case loading
    case unavailable
    case empty
    case ready

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "consultando"
        case .unavailable:
            return "indisponível"
        case .empty:
            return "ligada, sem patches nem provas publicadas"
        case .ready:
            return "disponível"
        }
    }
}

// MARK: - Judgment

/// Pure change-review sheet load grammar — face · spoken · pack.
enum ChangeReviewSheetJudgment {

    static let sheetHint = "aceitar ou rejeitar só com ações publicadas pelo servidor"

    static func face(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> ChangeReviewSheetFace {
        guard let review else {
            return loadFinished ? .unavailable : .loading
        }
        switch review.state {
        case .unavailable:
            return .unavailable
        case .available:
            if ChangeReviewJudgment.hasReviewSurface(review) {
                return .ready
            }
            return .empty
        }
    }

    /// Full sheet accessibility label (load + available supplements).
    static func spokenSheet(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> String {
        let face = face(loadFinished: loadFinished, review: review)
        switch face {
        case .loading:
            return "revisão de mudanças, consultando"
        case .unavailable:
            if review == nil {
                return "revisão de mudanças, indisponível"
            }
            return "revisão de mudanças indisponível"
        case .empty:
            return "revisão de mudanças ligada, sem patches nem provas publicadas"
        case .ready:
            return spokenReady(review!)
        }
    }

    static func spokenReady(_ review: AtlasTraceChangeReview) -> String {
        let patches = review.patches.count
        var parts = [
            "revisão de mudanças disponível",
            "\(patches) patch\(patches == 1 ? "" : "es")"
        ]
        if let risk = ChangeReviewJudgment.spokenSheetSupplement(from: review) {
            parts.append(risk)
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        loadFinished: Bool,
        review: AtlasTraceChangeReview?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(loadFinished: loadFinished, review: review)
        facts.append("review_sheet_face: \(face.productWord)")
        switch face {
        case .loading:
            absences.append("revisão ainda consultando")
        case .unavailable:
            absences.append("revisão indisponível neste recorte")
            if let reason = review?.reason, !reason.isEmpty {
                facts.append("review_reason: \(reason)")
            }
        case .empty:
            absences.append("revisão sem patches/checks/achados publicados")
        case .ready:
            if let review {
                facts.append("review_patches: \(review.patches.count)")
                facts.append("review_findings: \(review.review.findings.count)")
            }
        }
        return (facts, absences)
    }
}
