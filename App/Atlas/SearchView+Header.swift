import SwiftUI
import AtlasCore

struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")
            .accessibilityHint("fecha a busca")

            searchFieldCapsule
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}
