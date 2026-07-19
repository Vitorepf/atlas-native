import Foundation

/// Plano local exato da medição que o iPhone vai enfileirar.
///
/// A projeção aceita apenas suítes explicitamente selecionadas. O sentinel
/// `.all` depende do catálogo instalado no servidor e, sem esse denominador,
/// não pode prometer quantidade de runs na tela.
public struct AtlasArenaMeasurementPlan: Sendable, Equatable {
    public let engines: [String]
    public let suites: [String]
    public let arms: [AtlasArenaRunArm]
    public let runsPlanned: Int

    public var comparesAtlas: Bool {
        arms.contains(.baseline) && arms.contains(.withAtlas)
    }

    public init?(inputs: [AtlasArenaStartInput]) {
        guard !inputs.isEmpty, inputs.allSatisfy(\.isLocallyValidForSubmission) else {
            return nil
        }

        var engines: [String] = []
        var suites: [String] = []
        var arms: [AtlasArenaRunArm] = []
        var seenEngines = Set<String>()
        var seenSuites = Set<String>()
        var seenArms = Set<AtlasArenaRunArm>()
        var runsPlanned = 0

        for input in inputs {
            guard case .selected(let selectedSuites) = input.suites,
                  !selectedSuites.isEmpty else {
                return nil
            }
            if seenEngines.insert(input.engine).inserted {
                engines.append(input.engine)
            }
            for suite in selectedSuites where seenSuites.insert(suite).inserted {
                suites.append(suite)
            }
            for arm in input.arms where seenArms.insert(arm).inserted {
                arms.append(arm)
            }
            runsPlanned += selectedSuites.count * input.arms.count
        }

        guard runsPlanned > 0 else { return nil }
        self.engines = engines
        self.suites = suites
        self.arms = arms
        self.runsPlanned = runsPlanned
    }
}
