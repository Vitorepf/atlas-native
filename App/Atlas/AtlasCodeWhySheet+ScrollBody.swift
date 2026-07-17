import SwiftUI
import AtlasCore

// Why sheet scroll body — peel de AtlasCodeWhySheet.

extension AtlasCodeWhySheet {
    var whyScrollBody: some View {
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
}
