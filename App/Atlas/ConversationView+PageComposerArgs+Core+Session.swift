import SwiftUI
import AtlasCore

// Session args — peel de ConversationView+PageComposerArgs+Core.

extension ConversationView {
    func conversationComposerSessionArgs(
        focused: FocusState<Bool>.Binding
    ) -> (
        model: ConversationModel,
        session: AtlasSession,
        reduceMotion: Bool,
        focused: FocusState<Bool>.Binding
    ) {
        (
            model: model,
            session: session,
            reduceMotion: reduceMotion,
            focused: focused
        )
    }
}
