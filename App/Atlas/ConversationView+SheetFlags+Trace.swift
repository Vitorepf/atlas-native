import SwiftUI
import PhotosUI
import AtlasCore

// Trace sheet flags — peel de ConversationView+SheetFlags.

extension ConversationView {
    /// Folhas de revisão/artefato/steer abertas pelo composer/cockpit.
    var hasOpenTraceSheet: Bool {
        reviewTrace != nil || artifactTrace != nil || steerTrace != nil
    }
}
