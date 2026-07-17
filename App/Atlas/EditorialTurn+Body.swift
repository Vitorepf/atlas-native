import SwiftUI
import AtlasCore

// EditorialTurn body — peel de EditorialTurn.

extension EditorialTurn {
    var turnBody: some View {
        Group {
            if bubble.role == "user" {
                userTurn
            } else {
                assistantTurn
            }
        }
    }
}
