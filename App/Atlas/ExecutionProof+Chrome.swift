import SwiftUI
import AtlasCore

// Proof chrome — peel de ExecutionProof.

extension ExecutionProof {
    func proofChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            )
    }
}
