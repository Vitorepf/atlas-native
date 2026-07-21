import SwiftUI
import AtlasCore

// WAVE-156 density peel — decision list body

extension AutonomosDecisionSurface {
    // MARK: - List

    @ViewBuilder
    var listBody: some View {
        switch face {
        case .loading:
            faceChrome(face)
        case .failed:
            faceChrome(face)
        case .empty:
            faceChrome(face)
        case .items:
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    faceHeader(face)
                        .padding(.bottom, 18)
                    if let error = model.controlError, !error.isEmpty {
                        Text(error)
                            .font(AtlasFont.serifItalic(14))
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 12)
                            .accessibilityIdentifier(A11yID.autonomosControlError)
                    }
                    if let receipt = model.lastDecisionReceipt {
                        receiptLine(receipt)
                            .padding(.bottom, 14)
                    }
                    ForEach(items) { item in
                        decisionRow(item)
                    }
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .accessibilityLabel(face.spokenFace)
        }
    }
}
