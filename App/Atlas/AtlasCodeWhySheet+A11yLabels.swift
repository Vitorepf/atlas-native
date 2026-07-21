import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → AtlasCodeWhySheet+A11yLabels.swift

extension AtlasCodeWhySheet {
    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}

extension AtlasCodeWhySheet {
    func whySheetHistoryParts() -> [String] {
        guard model.phase == .loaded, let why = model.why else { return [] }
        if why.commits.isEmpty {
            return ["sem história neste recorte"]
        }
        var history = "\(why.commits.count) commit\(why.commits.count == 1 ? "" : "s")"
        if why.truncated { history += " de \(why.commitsTotal), história truncada" }
        return [history]
    }
}

extension AtlasCodeWhySheet {
    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        parts.append(contentsOf: whySheetHistoryParts())
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeWhySheet {
    var whyHeaderTitleBlock: some View {
        Group {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .atlasSans(9, .semibold)
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            whyHeaderTitleBlock
            headerTruncation
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}
