import AtlasCore
import SwiftUI

/// Home workspace visibility — peel de RootHomeSections+A11y.

extension RootHomeSections {
    /// WORKSPACES some quando não há pastas reais.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }
}
