import AtlasCore

extension AtlasArenaCompositeEngine {
    /// Cobertura incompleta — casca só rotula «parcial» com prova do contrato.
    var isPartialCoverage: Bool {
        coverage < 1.0
    }
}
