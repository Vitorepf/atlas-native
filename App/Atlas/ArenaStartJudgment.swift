import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Arena start-submit face (WAVE-055).
enum ArenaStartSubmitFace: Equatable {
    case ready
    case missing([String])
    case noEngines
    case noSuites

    var productWord: String {
        switch self {
        case .ready: return "ready"
        case .missing: return "missing"
        case .noEngines: return "no_engines"
        case .noSuites: return "no_suites"
        }
    }

    var allowsSubmit: Bool {
        if case .ready = self { return true }
        return false
    }

    var spokenLabel: String {
        switch self {
        case .ready:
            return "rodar medição"
        case .noEngines:
            return "rodar medição indisponível, nenhum motor publicado"
        case .noSuites:
            return "rodar medição indisponível, nenhuma suite com adapter"
        case .missing(let fields):
            if fields.isEmpty { return "rodar medição indisponível" }
            return "rodar medição indisponível, falta \(fields.joined(separator: ", "))"
        }
    }

    var spokenHint: String {
        switch self {
        case .ready:
            return "envia medição governada ao servidor"
        case .noEngines:
            return "aguarde o servidor publicar pelo menos um motor"
        case .noSuites:
            return "aguarde o servidor publicar suite com adapter"
        case .missing:
            return "preencha ator, motivo, suites, motor e braços"
        }
    }
}

/// Exclusive start-receipt face after submit.
enum ArenaStartReceiptFace: Equatable {
    case absent
    case enqueued
    case workerGap
    case started
    case other(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .enqueued: return "enqueued"
        case .workerGap: return "worker_gap"
        case .started: return "started"
        case .other: return "other"
        }
    }

    var statusLine: String {
        switch self {
        case .absent:
            return ""
        case .enqueued:
            return "na fila, ainda não iniciado"
        case .workerGap:
            return "na fila · worker desligado"
        case .started:
            return "iniciado"
        case .other(let status):
            return status
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem recibo de start"
        case .enqueued:
            return "recibo enfileirado, ainda não iniciado"
        case .workerGap:
            return "recibo enfileirado, worker de medição desligado no servidor"
        case .started:
            return "recibo, medição já iniciada"
        case .other(let status):
            return "recibo, status \(status)"
        }
    }
}

// MARK: - Judgment

/// Pure Arena start grammar — submit face · receipt face · pack · spoken.
enum ArenaStartJudgment {

    static let workerGapCopy =
        "worker de medição desligado no servidor — fila aguardando"
    static let newMeasurementLabel = "Nova medição"

    // MARK: Submit

    static func missingFields(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }

    static func submitFace(
        input: AtlasArenaStartInput,
        enginesEmpty: Bool,
        suitesEmpty: Bool
    ) -> ArenaStartSubmitFace {
        if enginesEmpty { return .noEngines }
        if suitesEmpty { return .noSuites }
        if input.isLocallyValidForSubmission { return .ready }
        return .missing(missingFields(input: input))
    }

    // MARK: Receipt

    static func receiptFace(
        _ receipt: AtlasArenaStartReceipt?
    ) -> ArenaStartReceiptFace {
        guard let receipt else { return .absent }
        // Worker gap elevates even when enqueued (operator must see server gap).
        if receipt.workerImplemented == false {
            return .workerGap
        }
        if receipt.started {
            return .started
        }
        if receipt.isEnqueued {
            return .enqueued
        }
        return .other(receipt.status)
    }

    static func receiptStatusLine(_ receipt: AtlasArenaStartReceipt) -> String {
        let face = receiptFace(receipt)
        if face.statusLine.isEmpty { return receipt.status }
        return face.statusLine
    }

    static func spokenReceipt(
        _ receipt: AtlasArenaStartReceipt,
        enginesCount: Int = 1,
        runsPlannedTotal: Int = 0
    ) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receiptFace(receipt).spokenFace)
        if enginesCount > 1, runsPlannedTotal > 0 {
            parts.append("\(enginesCount) motores, \(runsPlannedTotal) runs na fila")
        }
        if receipt.workerImplemented == false {
            parts.append(workerGapCopy)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        input: AtlasArenaStartInput?,
        receipt: AtlasArenaStartReceipt?,
        enginesPublished: Int,
        suitesPublished: Int
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("engines_published: \(enginesPublished)")
        facts.append("suites_published: \(suitesPublished)")
        if let input {
            let face = submitFace(
                input: input,
                enginesEmpty: enginesPublished == 0,
                suitesEmpty: suitesPublished == 0
            )
            facts.append("arena_start_submit_face: \(face.productWord)")
            facts.append("arms: \(input.arms.map(\.rawValue).joined(separator: ","))")
            if !input.engine.isEmpty {
                facts.append("engine: \(input.engine)")
            }
        } else {
            absences.append("input de start não montado neste recorte")
        }
        let rFace = receiptFace(receipt)
        facts.append("arena_start_receipt_face: \(rFace.productWord)")
        if let receipt {
            facts.append("receipt_hash: \(receipt.receiptHash)")
            facts.append("runs_planned: \(receipt.runsPlanned)")
            facts.append("worker_implemented: \(receipt.workerImplemented)")
            if let mid = receipt.measurementIdPublic {
                facts.append("measurement_id: \(mid)")
            }
        } else {
            absences.append("sem recibo de start neste recorte")
        }
        return (facts, absences)
    }
}
