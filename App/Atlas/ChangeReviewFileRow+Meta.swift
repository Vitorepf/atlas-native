import SwiftUI
import AtlasCore

// Meta do arquivo — peel de ChangeReviewFileRow.

extension ChangeReviewFileRow {
    var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var displayName: String { (file as NSString).lastPathComponent }

    var fileKindCaption: String? {
        if patch.createdFiles.contains(file) { return "novo" }
        if patch.deletedFiles.contains(file) { return "removido" }
        return nil
    }

    var fileLeading: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            }
            Spacer()
            fileTrailing
        }
    }
}
