import SwiftUI
import AtlasCore

// Meta do arquivo — peel de ChangeReviewFileRow.
// Leading → ChangeReviewFileRow+MetaLeading.swift

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
        fileLeadingRow
    }
}
