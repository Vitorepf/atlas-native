import SwiftUI
import AtlasCore

struct AutonomosInfoLine: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: 12)
    }
}

struct AutonomosControlReceiptLine: View {
    let receipt: AtlasAutonomosRunControlResponse

    var body: some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domAutonomos.opacity(0.1)))
    }
}

struct AutonomosErrorCard: View {
    let message: String

    var body: some View {
        Text(message).font(.footnote).foregroundStyle(AtlasTheme.domOperacional)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.1)))
    }
}
