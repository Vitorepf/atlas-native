import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — live/now/score/start/suite

// MARK: - ArenaLiveJudgment

// MARK: - ArenaLiveControlJudgment

// MARK: - Types

/// Exclusive Arena live-control face (WAVE-050).
enum ArenaLiveControlFace: Equatable {
    case empty
    case queued
    case running
    case stopping
    case attention(Int)
    case quietDone

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .attention: return "attention"
        case .quietDone: return "quiet_done"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Medição"
        case .queued: return "Na fila"
        case .running: return "Ao vivo"
        case .stopping: return "Parando"
        case .attention: return "Atenção"
        case .quietDone: return "Encerrada"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem corridas publicadas"
        case .queued:
            return "medição na fila"
        case .running:
            return "medição ao vivo"
        case .stopping:
            return "medição parando"
        case .attention(let n):
            return n == 1 ? "1 corrida falhou" : "\(n) corridas falharam"
        case .quietDone:
            return "medição encerrada sem falhas publicadas"
        }
    }
}

// MARK: - Judgment

/// Pure Arena live control — rank · face · canStop · pack.
enum ArenaLiveControlJudgment {

    /// Lower = higher attention / list priority.
    static func statusRank(_ status: AtlasArenaRunStatus) -> Int {
        switch status {
        case .running: return 0
        case .stopping: return 1
        case .failed: return 2
        case .completed: return 3
        case .stopped: return 4
        case .queued: return 5
        case .unknown: return 6
        }
    }

    static func rank(_ runs: [AtlasArenaLiveRun]) -> [AtlasArenaLiveRun] {
        runs.enumerated().sorted { lhs, rhs in
            let lr = statusRank(lhs.element.status)
            let rr = statusRank(rhs.element.status)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> ArenaLiveControlFace {
        if runs.isEmpty { return .empty }
        if runs.contains(where: { $0.status == .stopping })
            || primary?.status == .stopping {
            return .stopping
        }
        if runs.contains(where: { $0.status == .running })
            || primary?.status == .running {
            return .running
        }
        let failed = runs.filter { $0.status == .failed }.count
        if failed > 0 { return .attention(failed) }
        if runs.contains(where: { $0.status == .queued }) {
            return .queued
        }
        return .quietDone
    }

    static func canStop(primary: AtlasArenaLiveRun?) -> Bool {
        guard let primary else { return false }
        return primary.canStop == true && primary.measurementIdPublic != nil
    }

    static func packFacts(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(runs: runs, primary: primary)
        facts.append("arena_live_face: \(face.productWord)")
        if runs.isEmpty {
            absences.append("nenhuma corrida publicada neste recorte")
            return (facts, absences)
        }
        facts.append("runs: \(runs.count)")
        facts.append("can_stop: \(canStop(primary: primary))")
        for run in rank(runs).prefix(6) {
            facts.append(
                "run: \(run.suite) · \(run.status.rawValue)"
            )
        }
        if let primary {
            facts.append("primary_suite: \(primary.suite)")
            facts.append("primary_status: \(primary.status.rawValue)")
        } else {
            absences.append("sem corrida primary publicada")
        }
        return (facts, absences)
    }

    // MARK: Measurement presentation (WAVE-187)

    /// Progress · primary line · alerts · narrative · execution live list.
    /// Never invents cases or report text.
    static func packMeasurementFacts(
        progress: AtlasArenaLiveProgress?,
        primary: AtlasArenaLiveRun?,
        alertSuiteCount: Int,
        narrative: String?,
        liveRuns: [AtlasArenaLiveRun],
        includeLiveList: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        if let progress {
            facts.append(
                "measurement_progress: \(progress.completed)/\(progress.total) (\(progress.remaining) restantes)"
            )
        } else {
            absences.append("progresso de casos não publicado neste recorte")
        }

        if let run = primary {
            facts.append(
                "measurement_primary: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
            )
        } else {
            absences.append("corrida primary não publicada para medição")
        }

        facts.append(
            alertSuiteCount == 0
                ? "measurement_alerts: nenhuma exceção"
                : "measurement_alerts: \(alertSuiteCount) exceção(ões)"
        )

        if let narrative, !narrative.isEmpty {
            facts.append("measurement_narrative: \(narrative)")
        } else {
            absences.append("narrativa de relatório não publicada")
        }

        if includeLiveList {
            facts.append("measurement_live_runs: \(liveRuns.count)")
            let orderedLive = rank(liveRuns)
            for run in orderedLive.prefix(6) {
                facts.append(
                    "measurement_live: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
                )
            }
            if liveRuns.isEmpty {
                absences.append("nenhuma corrida live publicada")
            }
        }

        return (facts, absences)
    }
}

// MARK: - ArenaNowJudgment

// MARK: - Types

/// Exclusive Arena Premium “agora” phase face (WAVE-066).
enum ArenaNowFace: Equatable {
    case preparing
    case idle
    case queued
    case running
    case stopping
    case stopped
    case completed
    case failed

    var productWord: String {
        switch self {
        case .preparing: return "preparing"
        case .idle: return "idle"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .stopped: return "stopped"
        case .completed: return "completed"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .preparing: return "preparando a arena"
        case .idle: return "parada"
        case .queued: return "na fila"
        case .running: return "ao vivo"
        case .stopping: return "parando"
        case .stopped: return "parada pelo operador"
        case .completed: return "concluída"
        case .failed: return "interrompida"
        }
    }
}

/// Terminal chrome peel (title · subtitle · symbol · tone key).
struct ArenaNowTerminalChrome: Equatable {
    let title: String
    let subtitle: String
    let symbol: String
    let tone: ArenaPremiumTone
}

// MARK: - Judgment

/// Pure Arena now-phase grammar — face · terminal chrome · spoken · pack.
enum ArenaNowJudgment {
    static let productScreenTitle = "Arena"

    static let productNoEngineMeasured = "Nenhum motor medido"
    static let productNoEngineMeasuredBody = "Rode uma medição com pelo menos um motor para ver o ranking da frota."
    static let productNoRegression = "Nenhuma regressão ou falha publicada"
    static let productNoResultMeasured = "Nenhum resultado medido"
    static let productNoResultBody = "O primeiro resultado aparecerá quando uma suíte concluir."
    static let productNoPlanActive = "Nenhum plano ativo"

    static let productArmAbsenceHonesty = "Ausência de um braço permanece não medida."
    static let productCompareEnginesHint = "Escolha 2 ou mais para comparar motor contra motor."
    static let productWhatWeMeasure = "O que vamos medir?"
    static let productWhereAtlasRises = "Onde o Atlas sobe"
    static let spokenReloadArenaHint = "tenta carregar a Arena de novo"

    static func face(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool
    ) -> ArenaNowFace {
        if compositeNil {
            switch loadPhase {
            case .idle, .loading:
                return .preparing
            case .loaded, .failed:
                break
            }
        }
        switch livePhase ?? .idle {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(from livePhase: AtlasArenaLivePhase) -> ArenaNowFace {
        switch livePhase {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(terminal kind: ArenaPremiumTerminalKind) -> ArenaNowFace {
        switch kind {
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func terminalChrome(_ kind: ArenaPremiumTerminalKind) -> ArenaNowTerminalChrome {
        switch kind {
        case .stopping:
            return ArenaNowTerminalChrome(
                title: "Parada solicitada",
                subtitle: "Finalizando o caso atual",
                symbol: "hourglass",
                tone: .active
            )
        case .stopped:
            return ArenaNowTerminalChrome(
                title: "Medição parada",
                subtitle: "Resultados parciais preservados",
                symbol: "stop.circle",
                tone: .neutral
            )
        case .completed:
            return ArenaNowTerminalChrome(
                title: "Medição concluída",
                subtitle: "Resultado terminal confirmado",
                symbol: "checkmark.seal",
                tone: .positive
            )
        case .failed:
            return ArenaNowTerminalChrome(
                title: "Medição interrompida",
                subtitle: "O que concluiu foi preservado",
                symbol: "exclamationmark.triangle",
                tone: .negative
            )
        }
    }

    static func productIdleKicker() -> String { "Arena pronta" }
    static func productIdleTitle() -> String { "Nada medindo agora" }
    static func productIdleBody() -> String {
        "Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado."
    }

    static func productQueuedKicker() -> String { "Na fila" }
    static func productQueuedTitle() -> String { "Medição programada" }
    static func productQueuedHonestyLine() -> String {
        "Ainda não iniciado · nenhum progresso foi presumido."
    }

    static func productPreparingKicker() -> String { "Preparando a Arena" }
    static func productPreparingTitle() -> String { "Organizando as medições" }

    static func packFacts(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool,
        engineTitle: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            loadPhase: loadPhase,
            livePhase: livePhase,
            compositeNil: compositeNil
        )
        facts.append("arena_now_face: \(face.productWord)")
        if let engineTitle, !engineTitle.isEmpty {
            facts.append("arena_engine_title: \(engineTitle)")
        }
        switch face {
        case .preparing:
            absences.append("composite ainda carregando")
        case .idle:
            absences.append("nenhuma medição ao vivo")
        case .queued:
            facts.append("arena_now_queue: true")
        case .running:
            facts.append("arena_now_live: true")
        case .stopping, .stopped, .completed, .failed:
            facts.append("arena_now_terminal: true")
        }
        return (facts, absences)
    }
}

// MARK: - ArenaScoreJudgment

/// Estados exclusivos do instrumento de julgamento.
enum ArenaScoreJudgmentState: String, Equatable {
    case unmeasured
    case partial
    case published
    case regressed
    case quietHealthy
}

enum ArenaScoreJudgment {
    /// Escala canônica — uma voz em todas as faces.
    static let scaleCaption = "escala 0–10"
    static let productUnmeasured = "não medido"
    static let absenceNeverZero =
        "Resultados ausentes aparecem como não medidos, nunca como zero."

    // MARK: - Classification

    /// Motor composto: unmeasured | partial | published | regressed.
    static func state(
        composite: Double?,
        without: Double?,
        withAtlas: Double?,
        claimAllowed: Bool?,
        isPartialCoverage: Bool,
        hasRegression: Bool
    ) -> ArenaScoreJudgmentState {
        if hasRegression { return .regressed }
        let hasAny = composite != nil || without != nil || withAtlas != nil
        if !hasAny { return .unmeasured }
        if isPartialCoverage || claimAllowed == false { return .partial }
        if without != nil, withAtlas != nil { return .published }
        if composite != nil { return .partial }
        return .unmeasured
    }

    static func state(engine: AtlasArenaCompositeEngine, claimAllowed: Bool?) -> ArenaScoreJudgmentState {
        state(
            composite: engine.composite,
            without: engine.withoutAtlasComposite,
            withAtlas: engine.withAtlasComposite,
            claimAllowed: claimAllowed,
            isPartialCoverage: engine.isPartialCoverage,
            hasRegression: false
        )
    }

    // MARK: - Numbers (never fabricate)

    /// Δ com vs sem — só se **ambos** publicados; senão nil (não 0).
    static func pairedDelta(without: Double?, withAtlas: Double?) -> Double? {
        guard let without, let withAtlas else { return nil }
        return withAtlas - without
    }

    static func pairedDelta(engine: AtlasArenaCompositeEngine) -> Double? {
        pairedDelta(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite)
    }

    /// Lei Comparison: só mostra kicker/par se o par completo existe.
    static func shouldShowComparison(without: Double?, withAtlas: Double?) -> Bool {
        without != nil && withAtlas != nil
    }

    static func comparisonKicker(provisional: Bool, sourceSuite: Bool) -> String {
        if sourceSuite {
            return provisional
                ? "Último par · \(scaleCaption)"
                : "Comparação final · \(scaleCaption)"
        }
        return provisional
            ? "Índice do motor · \(scaleCaption)"
            : "Comparação final · \(scaleCaption)"
    }

    // MARK: - Kickers / voice

    static func resultsKicker(claimAllowed: Bool?) -> String {
        if claimAllowed == true { return "Última medição concluída · \(scaleCaption)" }
        return "Medição parcial · \(scaleCaption)"
    }

    static func fleetKicker(engineCount: Int) -> String {
        let n = engineCount
        return "Frota medida · \(n) \(n == 1 ? "motor" : "motores") · \(scaleCaption)"
    }

    static func spokenMeasuredEngine(_ engineID: String) -> String {
        "Motor medido, \(ArenaDisplay.engine(engineID))"
    }

    static let spokenMeasuredEngineHint = "Abre a lista dos outros motores medidos"

    static func capabilitiesKicker() -> String {
        "Perfil medido · \(scaleCaption)"
    }

    static func alertsKicker(hasAlerts: Bool) -> (text: String, tone: ArenaPremiumTone) {
        if hasAlerts {
            return ("Exceções que pedem atenção · \(scaleCaption)", .negative)
        }
        return ("Sem exceções · quiet-healthy", .positive)
    }

    /// Voz única de regressão (Alerts ≡ Results).
    static func regressionDetail(delta: Double?) -> String {
        "\(ArenaFormat.signed(delta)) · regressão"
    }

    // MARK: - Spoken (≡ visual)

    static func spokenScore(_ value: Double?) -> String {
        guard value != nil else { return productUnmeasured }
        return "\(ArenaFormat.score(value)) de 10"
    }

    static func spokenPair(without: Double?, withAtlas: Double?) -> String {
        guard shouldShowComparison(without: without, withAtlas: withAtlas) else {
            return "par com/sem Atlas \(productUnmeasured)"
        }
        let d = pairedDelta(without: without, withAtlas: withAtlas)
        return "Sem Atlas \(ArenaFormat.score(without)), com Atlas \(ArenaFormat.score(withAtlas)), diferença \(ArenaFormat.signed(d))"
    }

    static func spokenEngine(_ engine: AtlasArenaCompositeEngine) -> String {
        let name = ArenaDisplay.engine(engine.engine)
        if let mult = engine.atlasMultiplier {
            return "\(name), multiplicador \(ArenaFormat.multiplier(mult)), \(spokenPair(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite))"
        }
        if engine.composite == nil && engine.withoutAtlasComposite == nil && engine.withAtlasComposite == nil {
            return "\(name), \(productUnmeasured)"
        }
        return "\(name), \(spokenPair(without: engine.withoutAtlasComposite, withAtlas: engine.withAtlasComposite))"
    }

    // MARK: Pack (WAVE-181)

    /// Mid-pack scoreboard state — never fabricates 0 or incomplete Δ.
    static func packFacts(
        engine: AtlasArenaCompositeEngine?,
        claimAllowed: Bool?,
        regressionCount: Int = 0,
        attentionCount: Int = 0
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        guard let engine else {
            facts.append("score_state: \(ArenaScoreJudgmentState.unmeasured.rawValue)")
            absences.append(productUnmeasured)
            absences.append(absenceNeverZero)
            return (facts, absences)
        }

        let face = state(engine: engine, claimAllowed: claimAllowed)
        // Host suite regressions elevate state without inventing engine flags.
        let scoreState: ArenaScoreJudgmentState =
            (regressionCount > 0 || attentionCount > 0) ? .regressed : face

        facts.append("score_state: \(scoreState.rawValue)")
        facts.append("score_engine: \(ArenaDisplay.engine(engine.engine))")
        if let composite = engine.composite {
            facts.append("score_composite: \(ArenaFormat.score(composite))")
        } else {
            absences.append("composite \(productUnmeasured)")
        }
        if let without = engine.withoutAtlasComposite {
            facts.append("score_without_atlas: \(ArenaFormat.score(without))")
        } else {
            absences.append("braço sem Atlas \(productUnmeasured)")
        }
        if let withAtlas = engine.withAtlasComposite {
            facts.append("score_with_atlas: \(ArenaFormat.score(withAtlas))")
        } else {
            absences.append("braço com Atlas \(productUnmeasured)")
        }
        if let delta = pairedDelta(engine: engine) {
            facts.append("score_delta_atlas: \(ArenaFormat.signed(delta))")
        } else {
            absences.append("par com/sem Atlas incompleto — sem Δ inventado")
        }
        if let mult = engine.atlasMultiplier {
            facts.append("score_multiplier: \(ArenaFormat.multiplier(mult))")
        }
        if engine.isPartialCoverage {
            facts.append("score_coverage: partial")
        }
        if claimAllowed == false {
            absences.append("claim_allowed=false — medição parcial, não trate como veredito final")
        }
        if regressionCount > 0 {
            facts.append("score_suite_regressions: \(regressionCount)")
        }
        absences.append(absenceNeverZero)
        return (facts, absences)
    }
}

// MARK: - ArenaStartJudgment

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
    static let productNewMeasurement = "Nova medição"

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

// MARK: - ArenaSuiteJudgment

// MARK: - Types

/// Exclusive suite-drill face (WAVE-059).
enum ArenaSuiteFace: Equatable {
    case empty
    case quiet
    case regression(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .quiet: return "quiet"
        case .regression: return "regression"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Suíte"
        case .quiet: return "Resultado da suíte"
        case .regression: return "Regressão detectada"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "nenhum motor neste recorte"
        case .quiet:
            return "suíte sem regressão publicada"
        case .regression(let n):
            return n == 1
                ? "1 motor com regressão"
                : "\(n) motores com regressão"
        }
    }
}

// MARK: - Judgment

/// Pure suite engines grammar — rank · face · spoken · pack.
enum ArenaSuiteJudgment {

    static let spokenClose = "fechar detalhes da suite"
    static let productTitle = "Suite"
    static let spokenCloseHint = "volta para a Arena"
    static let spokenSheetHint = "scores, casos e duração só quando o servidor publica"
    static let spokenCasesHint = "Abre os casos desta corrida"

    /// Regressed first → measured score desc → wire-stable.
    static func rank(_ engines: [AtlasArenaSuiteEngine]) -> [AtlasArenaSuiteEngine] {
        engines.enumerated().sorted { lhs, rhs in
            let lReg = lhs.element.regressed
            let rReg = rhs.element.regressed
            if lReg != rReg { return lReg && !rReg }
            let lScore = lhs.element.score
            let rScore = rhs.element.score
            switch (lScore, rScore) {
            case let (l?, r?):
                if l != r { return l > r }
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                break
            }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(for suite: AtlasArenaSuite) -> ArenaSuiteFace {
        if suite.engines.isEmpty { return .empty }
        let regressed = suite.engines.filter(\.regressed).count
        if regressed > 0 { return .regression(regressed) }
        return .quiet
    }

    static func spokenEngine(_ engine: AtlasArenaSuiteEngine) -> String {
        var parts = [engine.engine, "score \(ArenaFormat.score(engine.score))"]
        if engine.regressed { parts.append("regressão detectada") }
        if let cases = casesCaption(for: engine) { parts.append(cases) }
        if let duration = durationCaption(for: engine) { parts.append(duration) }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) pontos no histórico")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenSuite(_ suite: AtlasArenaSuite) -> String {
        let face = face(for: suite)
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), \(face.spokenFace)"
        }
        let parts = [
            "suite \(suite.suite)",
            "\(n) motor\(n == 1 ? "" : "es")",
            face.spokenFace
        ]
        return parts.joined(separator: ", ")
    }

    static func casesCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let total = engine.casesTotal else { return nil }
        var parts: [String] = []
        if let passed = engine.casesPassed { parts.append("ok \(passed)") }
        if let failed = engine.casesFailed { parts.append("falha \(failed)") }
        parts.append("de \(total) casos")
        return parts.joined(separator: " · ")
    }

    static func durationCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let ms = engine.durationAvgMs else { return nil }
        return "duração média \(ArenaDisplay.duration(ms: ms)) por caso"
    }

    static func packFacts(for suite: AtlasArenaSuite) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(for: suite)
        facts.append("arena_suite_face: \(face.productWord)")
        facts.append("suite: \(suite.suite)")
        facts.append("engines: \(suite.engines.count)")
        facts.append("runs_total: \(suite.runsTotal)")
        if suite.engines.isEmpty {
            absences.append("nenhum motor na suíte neste recorte")
            return (facts, absences)
        }
        for engine in rank(suite.engines).prefix(6) {
            var line = "engine: \(engine.engine)"
            if engine.regressed { line += " · regressed" }
            if let score = engine.score {
                line += " · score \(score)"
            } else {
                line += " · unmeasured"
            }
            facts.append(line)
        }
        let unmeasured = suite.engines.filter { $0.score == nil }.count
        if unmeasured > 0 {
            absences.append("\(unmeasured) motor(es) sem score publicado")
        }
        return (facts, absences)
    }

    // MARK: Composite chart spoken (IDLE · was ArenaCompositeChartA11y)

    static func spokenCompositeChart(_ engine: AtlasArenaCompositeEngine) -> String {
        let plotted = engine.history.filter {
            $0.composite != nil || $0.withAtlas != nil || $0.withoutAtlas != nil
        }
        guard !plotted.isEmpty else { return "" }
        var parts = ["gráfico de histórico do motor \(engine.engine)"]
        let rounds = plotted.count
        parts.append(rounds == 1 ? "1 rodada" : "\(rounds) rodadas")
        if plotted.contains(where: { $0.composite != nil }) { parts.append("linha composta") }
        if plotted.contains(where: { $0.withAtlas != nil }) { parts.append("linha com Atlas") }
        if plotted.contains(where: { $0.withoutAtlas != nil }) { parts.append("linha sem Atlas") }
        return parts.joined(separator: ", ")
    }
}
