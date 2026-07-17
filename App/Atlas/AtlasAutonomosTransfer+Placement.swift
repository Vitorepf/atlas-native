import AtlasCore

// Placement predicates — peel de AtlasAutonomosTransfer+UI.

extension AtlasAutonomosRuntimePlacement {
    /// Qualquer campo publicado pelo lock — ausência não vira placeholder na casca.
    var hasVerifiedPlacement: Bool {
        host?.nonEmpty != nil
            || environment?.nonEmpty != nil
            || workspace?.nonEmpty != nil
            || repository?.nonEmpty != nil
            || branch?.nonEmpty != nil
            || acquiredAt?.nonEmpty != nil
            || leaseTTLSeconds != nil
    }
}
