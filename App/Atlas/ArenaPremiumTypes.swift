import SwiftUI
import AtlasCore

enum ArenaPremiumTab: String, CaseIterable, Identifiable {
    case now = "Agora"
    case fleet = "Frota"
    case capabilities = "Capac."
    case results = "Motor"

    var id: String { rawValue }

    /// Identificador estável p/ a11y (não depende do rótulo curto da aba).
    var a11yKey: String {
        switch self {
        case .now: "agora"
        case .fleet: "frota"
        case .capabilities: "capacidades"
        case .results: "motor"
        }
    }
}

enum ArenaPremiumDestination: String, Identifiable, Hashable {
    case execution
    case plan
    case queue
    case alerts
    case results

    var id: String { rawValue }
}

enum ArenaPremiumTone {
    case muted
    case neutral
    case active
    case positive
    case negative

    var color: Color {
        switch self {
        case .muted: AtlasTheme.textTertiary
        case .neutral: AtlasTheme.textSecondary
        case .active: AtlasTheme.accent
        case .positive: AtlasTheme.textPrimary
        case .negative: AtlasTheme.alert
        }
    }
}

extension ArenaModel {
    var arenaSelectedEngineID: String? {
        capabilitiesEngineSelection ?? composite?.engines.first?.engine
    }

    var arenaPrimaryEngine: AtlasArenaCompositeEngine? {
        guard let selected = arenaSelectedEngineID else { return composite?.engines.first }
        return composite?.engines.first { $0.engine == selected }
            ?? composite?.engines.first
    }

    var arenaPrimaryRun: AtlasArenaLiveRun? {
        livePresentation?.primaryRun
    }

    var arenaPrimarySuite: AtlasArenaSuite? {
        guard let run = arenaPrimaryRun else { return scoreboard?.suites.first }
        return scoreboard?.suites.first { $0.suite == run.suite }
    }

    var arenaPrimaryMeasurementRuns: [AtlasArenaLiveRun] {
        guard let primary = arenaPrimaryRun else { return [] }
        guard let measurement = primary.measurementIdPublic else { return [primary] }
        return liveRuns?.runs.filter { $0.measurementIdPublic == measurement } ?? [primary]
    }

    var arenaRegressionCount: Int {
        scoreboard?.suites.filter(\.hasRegression).count ?? 0
    }

    var arenaCoverageText: String {
        guard let composite else { return "não medida" }
        return "\(composite.suitesMeasured)/\(composite.suitesTotal) suítes"
    }

    var arenaAlertSuiteCount: Int {
        var suites = Set(scoreboard?.suites.filter(\.hasRegression).map(\.suite) ?? [])
        suites.formUnion(report?.attentionSuites.map(\.suite) ?? [])
        return suites.count
    }

    /// Título humano do motor ao vivo — nunca o literal "motor desconhecido".
    var arenaLiveEngineTitle: String {
        if let id = arenaPrimaryRun?.engine, !id.isEmpty {
            return ArenaDisplay.engine(id)
        }
        if let preferred = preferredEngine, !preferred.isEmpty {
            return ArenaDisplay.engine(preferred)
        }
        if let composite = arenaPrimaryEngine?.engine {
            return ArenaDisplay.engine(composite)
        }
        return "Medição ao vivo"
    }
}
