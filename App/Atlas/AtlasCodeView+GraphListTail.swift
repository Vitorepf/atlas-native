import SwiftUI
import AtlasCore

// Cauda pagination/mirror/week — peel de AtlasCodeView+GraphList.
// Truncation → AtlasCodeView+GraphListTail+Truncation.swift
// Mirror → +GraphListTail+Mirror.swift · Week → +GraphListTail+WeekTail.swift

extension AtlasCodeView {
    @ViewBuilder
    func graphListTail(graph: AtlasCodeGraphResponse) -> some View {
        graphListTruncationCaption(graph)
        graphListMirrorCard
        graphListWeekTail
    }
}
