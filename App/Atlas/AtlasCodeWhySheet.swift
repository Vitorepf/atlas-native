import SwiftUI
import AtlasCore

struct AtlasCodeWhySheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWhyModel
    let repo: String
    let file: String

    init(client: AtlasClient, repo: String, file: String) {
        _model = State(initialValue: AtlasCodeWhyModel(client: client))
        self.repo = repo
        self.file = file
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: whyContentPhaseID)
            }
        }
        .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
        .accessibilityIdentifier(A11yID.whySheet)
        .accessibilityLabel(whySheetSpokenLabel)
        .accessibilityHint(Self.sheetHint)
    }
}
