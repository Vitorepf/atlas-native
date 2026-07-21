import SwiftUI
import AtlasCore

// Conteúdo do estado available — struct-mãe RECONSTRUÍDA pós-merge (os peels
// de Sections a estendem; a definição não chegou ao merge).

struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        reviewSections
    }
}
