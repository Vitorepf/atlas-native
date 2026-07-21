import SwiftUI
import AtlasCore

struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            searchBackButton
            searchFieldCapsule
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}
