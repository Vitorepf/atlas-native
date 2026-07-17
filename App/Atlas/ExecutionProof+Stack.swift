import SwiftUI
import AtlasCore

// Execution proof stack — peel de ExecutionProof.

extension ExecutionProof {
    var proofStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
    }
}
