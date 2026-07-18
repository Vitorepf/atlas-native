import SwiftUI
import AtlasCore

struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkA11y
    }
}
