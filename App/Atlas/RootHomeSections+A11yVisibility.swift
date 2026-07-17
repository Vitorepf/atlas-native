import AtlasCore
import SwiftUI

/// Home workspace visibility — peel de RootHomeSections+A11y.

extension RootHomeSections {
    /// Chips só quando há workspaces reais — Livres/Todas ficam na linha CONVERSAS.
    var showsWorkspaceChips: Bool { !session.workspaces.isEmpty }

    /// WORKSPACES some quando não há pastas — "Todas" já vive nos chips.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }
}
