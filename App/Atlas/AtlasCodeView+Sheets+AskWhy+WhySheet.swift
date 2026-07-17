import SwiftUI
import AtlasCore

// Why file sheet — peel de AtlasCodeView+Sheets+AskWhy.

extension AtlasCodeAskWhySheetsModifier {
    func askWhyWhySheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $whyFileTarget) { target in
                AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}
