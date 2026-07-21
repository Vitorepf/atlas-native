import SwiftUI
import PhotosUI
import AtlasCore

// Composer VStack — peel de ConversationComposer+Shell.

extension ConversationComposer {
    @ViewBuilder
    var composerShellVBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
    }
}
