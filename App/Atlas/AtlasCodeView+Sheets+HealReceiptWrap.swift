import SwiftUI
import AtlasCore

// Heal receipt wrap — peel de AtlasCodeView+Sheets+Provenance.

extension AtlasCodeSheetsModifier {
    @ViewBuilder
    func healReceiptWrap<Content: View>(on content: Content) -> some View {
        healReceiptSheet(on: content)
    }
}
