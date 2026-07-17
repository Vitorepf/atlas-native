import SwiftUI
import AtlasCore

// Campos de idade do inbox — peel de AutonomosDetailWorkRows+Inbox.

enum AutonomosDetailInboxAge {
    @ViewBuilder
    static func ageFields(_ item: AtlasAutonomosInboxItem) -> some View {
        if let createdAt = item.createdAt {
            AutonomosDetailChrome.field("criado", createdAt)
            if let date = AtlasTime.date(createdAt) {
                AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
            }
        }
    }
}
