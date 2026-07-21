import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Autônomos hub surface face (WAVE-096).
enum AutonomosHubFace: Equatable {
    case needsBind
    case awaiting(Int)
    case live
    case quiet

    var productWord: String {
        switch self {
        case .needsBind: return "needs_bind"
        case .awaiting: return "awaiting"
        case .live: return "live"
        case .quiet: return "quiet"
        }
    }

    var spokenFace: String {
        switch self {
        case .needsBind:
            return "precisa ligar área"
        case .awaiting(let n):
            return AutonomosHubVestment.awaiting(n).spokenFace
        case .live:
            return AutonomosHubVestment.live.spokenFace
        case .quiet:
            return AutonomosHubVestment.quiet.spokenFace
        }
    }
}

/// Control/transfer receipt presentation tone.
enum AutonomosReceiptTone: Equatable {
    case silent
    case ok
    case error

    var productWord: String {
        switch self {
        case .silent: return "silent"
        case .ok: return "ok"
        case .error: return "error"
        }
    }
}

// MARK: - Judgment

/// Pure hub surface grammar — face · kicker · spoken · receipt tone · pack.
enum AutonomosHubJudgment {

    // MARK: Face

    static func face(
        vestment: AutonomosHubVestment,
        needsAreaBind: Bool
    ) -> AutonomosHubFace {
        if needsAreaBind { return .needsBind }
        switch vestment {
        case .awaiting(let n): return .awaiting(n)
        case .live: return .live
        case .quiet: return .quiet
        }
    }

    // MARK: Kicker / spoken

    static func kickerLine(vestment: AutonomosHubVestment, ageLabel: String) -> String {
        "\(vestment.kicker) · \(ageLabel)"
    }

    static func spokenHub(
        name: String,
        vestment: AutonomosHubVestment,
        controlFace: AutonomosRunControlFace,
        needsAreaBind: Bool
    ) -> String {
        let hub = face(vestment: vestment, needsAreaBind: needsAreaBind)
        var parts = [name, hub.spokenFace, controlFace.spokenFace, vestment.heroTitle]
        if needsAreaBind {
            parts.append("área não ligada")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Receipt tone

    /// Prefer structured applied=false; fallback lexical markers on published line.
    static func receiptTone(
        line: String?,
        controlApplied: Bool? = nil
    ) -> AutonomosReceiptTone {
        guard let line, !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .silent
        }
        if let controlApplied, controlApplied == false {
            return .error
        }
        let lower = line.lowercased()
        let errorMarks = ["não", "erro", "falha", "recus", "negad", "timeout", "indispon"]
        if errorMarks.contains(where: { lower.contains($0) }) {
            return .error
        }
        return .ok
    }

    static func showsControlFaceLine(_ controlFace: AutonomosRunControlFace) -> Bool {
        controlFace != .unbound
    }

    // MARK: Pack

    static func packFacts(
        unitName: String,
        vestment: AutonomosHubVestment,
        controlFace: AutonomosRunControlFace,
        needsAreaBind: Bool,
        canTransfer: Bool,
        hasControlReceipt: Bool,
        hasTransferReceipt: Bool,
        controlApplied: Bool? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let hub = face(vestment: vestment, needsAreaBind: needsAreaBind)
        facts.append("hub_face: \(hub.productWord)")
        facts.append("hub_unit: \(unitName)")
        facts.append("hub_control: \(controlFace.productWord)")
        facts.append("hub_vestment: \(vestment.productWord)")
        if needsAreaBind {
            facts.append("hub_needs_bind: true")
        }
        if canTransfer {
            facts.append("hub_can_transfer: true")
        } else {
            absences.append("transferência não disponível neste hub")
        }
        if hasControlReceipt {
            facts.append("hub_control_receipt: published")
            if let controlApplied {
                facts.append("hub_control_applied: \(controlApplied ? "yes" : "no")")
            }
        } else {
            absences.append("sem recibo de controle no hub")
        }
        if hasTransferReceipt {
            facts.append("hub_transfer_receipt: published")
        } else {
            absences.append("sem recibo de transfer no hub")
        }
        return (facts, absences)
    }

    // MARK: Self-build CTA spoken (WAVE-104)

    static let selfBuildReceiptSpoken =
        "O Atlas melhorou o próprio app, recibo com merge comprovado"

}
