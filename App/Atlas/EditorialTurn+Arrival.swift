import SwiftUI
import AtlasCore

// Arrival animation — peel de EditorialTurn.

extension EditorialTurn {
    var arrivalModifiers: some View {
        EmptyView()
    }

    func applyArrival<Content: View>(_ content: Content) -> some View {
        content
            .opacity(placed ? 1 : 0)
            .offset(y: placed ? 0 : 12)
            .onAppear {
                if reduceMotion { placed = true }
                else { withAnimation(AtlasMotion.arrival) { placed = true } }
            }
    }
}
